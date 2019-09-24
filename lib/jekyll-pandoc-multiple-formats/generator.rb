# Copyright (c) 2012-2018 Nicolás Reynolds <fauno@endefensadelsl.org>
#               2012-2013 Mauricio Pasquier Juan <mpj@endefensadelsl.org>
#               2013      Brian Candler <b.candler@pobox.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Jekyll

class PandocGenerator < Generator
  safe true

  attr_accessor :site, :config

  def generate_post_for_output(post, output)
    Jekyll.logger.debug 'Pandoc:', post.data['title']

    pandoc_file = PandocFile.new(@site, output, post)
    return unless pandoc_file.write

    @site.keep_files << pandoc_file.relative_path
    @pandoc_files << pandoc_file
  end

  def generate_category_for_output(category, posts, output)
    Jekyll.logger.info 'Pandoc:', "Generating category #{category}"
    posts.sort!
    pandoc_file = PandocFile.new(@site, output, posts, category)

    if @site.keep_files.include? pandoc_file.relative_path
      Jekyll.logger.warn 'Pandoc:',
        "#{pandoc_file.relative_path} is a category file AND a post file. Change the category name to fix this"
      return
    end

    return unless pandoc_file.write

    @site.keep_files << pandoc_file.relative_path
    @pandoc_files << pandoc_file
  end

  # Add covers to PDFs after building ready for print files
  def add_cover(pandoc_file)
    return unless pandoc_file.has_cover?
    # Generate the cover
    return unless pandoc_file.pdf_cover!

    united_output = pandoc_file.path.gsub(/\.pdf\Z/, '-cover.pdf')
    united_file = JekyllPandocMultipleFormats::Unite
      .new(united_output,
        [pandoc_file.pdf_cover,pandoc_file.path,pandoc_file.pdf_contra].compact,
        ['-', pandoc_file.posts.first.data['pages'] || '2-', '-'])

    Jekyll.logger.info pandoc_file.pdf_contra

    return unless united_file.write

    # Replace the original file with the one with cover
    FileUtils.rm_f(pandoc_file.path)
    FileUtils.mv(united_output, pandoc_file.path)
  end

  def general_full_for_output(output)
    title = @site.config.dig('title')
    Jekyll.logger.info 'Pandoc:', "Generating full file #{title}"
    # For parts to make sense, we order articles by date and then by
    # category, so each category is ordered by date.
    #
    # cat1 - art1
    # cat1 - art3
    # cat2 - art2
    full = @site.posts.docs.reject { |p| p.data.dig('full') }.sort_by do |p|
      [ p.data['date'], p.data['categories'].first.to_s ]
    end

    full_file = PandocFile.new(@site, output, full, title, { full: true })
    full_file.write
    @site.keep_files << full_file.relative_path
    @pandoc_files << full_file
  end

  def generate(site)
    @site     ||= site
    @config   ||= JekyllPandocMultipleFormats::Config.new(@site.config['pandoc'])

    return if @config.skip?

    # we create a single array of files
    @pandoc_files = []

    @config.outputs.each_pair do |output, _|
      Jekyll.logger.info 'Pandoc:', "Generating #{output}"

      # We only want the collections that are rendered, including posts
      collections = @site.config['collections'].select do |c,v|
        v['output'] == true
      end.keys

      collections.each do |collection|
        @site.collections[collection].docs.each do |post|
          Jekyll::Hooks.trigger :posts, :pre_render, post, { format: output }
          generate_post_for_output(post, output) if @config.generate_posts?
          Jekyll::Hooks.trigger :posts, :post_render, post, { format: output }
        end
      end

      if @config.generate_categories?
        @site.post_attr_hash('categories').each_pair do |title, posts|
          generate_category_for_output title, posts, output
        end
      end

      general_full_for_output(output) if @config.generate_full_file?
    end

    @pandoc_files.each do |pandoc_file|
      # If output is PDF, we also create the imposed PDF
      next unless pandoc_file.pdf?

      cover = @site.config['collections'][pandoc_file.collection]
        .fetch('cover', 'after')

      add_cover(pandoc_file) if cover == 'before'

      if @config.imposition?

        imposed_file = JekyllPandocMultipleFormats::Imposition
          .new(pandoc_file.path, pandoc_file.papersize,
          pandoc_file.sheetsize, pandoc_file.signature)

        imposed_file.write
        @site.keep_files << imposed_file.relative_path(@site.dest)
      end

      # If output is PDF, we also create the imposed PDF
      if @config.binder?

        binder_file = JekyllPandocMultipleFormats::Binder
          .new(pandoc_file.path, pandoc_file.papersize,
          pandoc_file.sheetsize)

        binder_file.write
        @site.keep_files << binder_file.relative_path(@site.dest)
      end

      add_cover(pandoc_file) if cover == 'after'
    end
  end
end
end
