module Rasputin
  class HandlebarsTemplate < Tilt::Template
    def self.default_mime_type
      'application/javascript'
    end

    def prepare; end

    def evaluate(scope, locals, &block)
      if scope.pathname.to_s =~ /\.raw\.(handlebars|hjs|hbs)/
        handlebar_template = "Ember.TEMPLATES[#{template_path(scope.logical_path).inspect}] = Handlebars.compile(#{indent(data).inspect});\n"
        initialize_uncomiled = "if (typeof Ember.UNCOMPILED_TEMPLATES === 'undefined') { Ember.UNCOMPILED_TEMPLATES = {};};"
        uncompiled_template = "Ember.UNCOMPILED_TEMPLATES[#{template_path(scope.logical_path).inspect}] = #{indent(data).inspect};\n"
        handlebar_template + "\n" + initialize_uncomiled + "\n" + uncompiled_template
      else
        if Rails.configuration.rasputin.precompile_handlebars
          func = Rasputin::Handlebars.compile(data)
          "Ember.TEMPLATES[#{template_path(scope.logical_path).inspect}] = Ember.Handlebars.template(#{func});"
        else
          "Ember.TEMPLATES[#{template_path(scope.logical_path).inspect}] = Ember.Handlebars.compile(#{indent(data).inspect});"
        end
      end
    end

    private
    
    def template_path(path)
      path = path.split('/')
      path.delete('templates')
      path.join(Rails.configuration.rasputin.template_name_separator)
    end

    def indent(string)
      string.gsub(/$(.)/m, "\\1  ").strip
    end
  end
end
