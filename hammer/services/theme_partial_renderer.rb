
class ThemePartialRenderer
  def initialize(args)
    @tag = args[:tag]
    @template = args[:template]
    @theme = load_theme(args[:theme])

    # @parser = @template.radius_parser
  end

  def render(name, options = {})
    options = options.with_indifferent_access
    file_name = normalize_partial_name(name, options)
    file_path = find_partial(file_name)

    # raise Slate::Errors::TemplateNotFound.new("Could not find partial '#{file_name}' in '#{@theme.name}' theme.") unless file_path.present?

    # binding.pry

    unless file_path.present?
      content = "Partial Not Found: Could not find partial '#{file_name}' in '#{@theme}' theme."
    else
      content = File.read file_path
    end

    @tag.globals.context.radius_parser.parse content

    # @parser.parse content
  end

  private

  def load_theme(theme_name)
    theme = if theme_name.nil?
      @tag.globals.context.theme_root
    else
      # Theme.find_by_name(theme_name)
      Pathname.new([@tag.globals.context.document_root,theme_name].join('/'))
    end

    # raise Slate::Errors::TemplateNotFound.new("Could not find theme: #{theme_name}") unless theme.present?
    theme

  end


  def load_paths
    # Paths in order of significance:
    # - The template directory set via the current Radius parser
    # - The directory of the current template
    # - The template directory of the Theme passed into this ThemePartialRenderer
    #
    # The paths will be searched in the order above for the named partial.
    # [@parser.context.globals.template_dir, @template.file_path, @theme.template_dir].compact

    context_path = @tag.globals.context.filesystem_path.parent
    theme_dir = Pathname.new([@theme,'views'].join('/'))
    file_path = Pathname.new(@template.parent)
    layouts_path = Pathname.new([theme_dir,'layouts'].join('/'))
    paths = [context_path, file_path, theme_dir,layouts_path].compact

    paths

  end

  def find_partial(name)
    load_paths.map{ |path| File.join(path, name) }.select { |path| File.exists? path }.first
  end

  def default_format
    #'.' + @template.format
    '.html'
  end

  def normalize_partial_name(name, options = {})
    return nil unless name.present?

    dirname = File.dirname(name)
    extension = File.extname(name)
    basename = File.basename(name, extension)

    filename = basename
    filename = filename.prepend('_') unless filename[0] == '_'
    filename += "-#{options['version']}" if options['version'].present?
    filename += extension.present? ? extension : default_format

    dirname == '.' ? filename : File.join(dirname, filename)
  end

  #   protected
  #   def render_with_radius
  #     @context.radius_parser.parse @content
  #   end
end
