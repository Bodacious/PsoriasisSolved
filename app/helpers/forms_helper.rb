module FormsHelper

  class KatanaCodeFormBuilder < ActionView::Helpers::FormBuilder

    # ActionView::Helpers::FormHelper and ActionView::Helpers::FormBuilder
    # methods each have different args. This hash stores the names of the args
    # and the methods that have those args in order to DRY up the method aliases
    # defined below.
    METHOD_NAMES_FOR_ARG_SETS = {

      'method,options={}' => %w{
        email_field file_field
        number_field password_field phone_field range_field url_field
        search_field telephone_field text_area text_field
      },

      "method,collection,value_method,text_method,options={},html_options={}" => %w{
        collection_select
      },

      "method,options={},html_options={}" => %w{date_select datetime_select time_select},

      "method,choices,options={},html_options={}" => %w{ select }
    }

    for args_set, method_names in METHOD_NAMES_FOR_ARG_SETS

      html_class_in = args_set.index("html_options") ? 'html_options' : 'options'
      args_without_defaults = args_set.gsub(/\=[^,]+/, '')
      for method_name in method_names

        method_str =  <<-RUBY
          def #{method_name}_with_error_field(#{args_set})
            update_options_with_form_control_class! #{html_class_in}
            content = #{method_name}_without_error_field(#{args_without_defaults})
            append_error_field_to_content!(content, method, options)
          end
        RUBY

        # Subtracting 2 from the __LINE__ var for accurate error messages
        class_eval(method_str, __FILE__, __LINE__-2)
        alias_method_chain method_name, :error_field
      end

    end

    def group(options ={}, &block)
      @template.form_group(options, &block)
    end

    def error_messages
      @template.error_messages_for(object)
    end

    def addon_icon(content = nil)
      content ||= @template.content_tag(:span, nil, class: 'caret')
      @template.content_tag(:span, content, class: 'input-group-addon')
    end

    def fieldset(options = {}, &block)
      @template.form_fieldset(options, &block)
    end

    def legend(content, options ={})
      @template.form_legend(content, options)
    end

    def hours_select(method, options = {}, html_options ={})
      update_options_with_class!(html_options, 'hours-select input-xs')
      options.update({
        ampm: true, ignore_date: true,
        include_seconds: false,
        minute_step: 15,
        prompt: true,
        error_field: false,
        time_separator: ''
      })
      time_select(method, options, html_options)
    end

    def hours_label(method, text = nil, options = {}, &block)
      update_options_with_class!(options, 'hours-label')
      label(method, text, options, &block)
    end

    def hours_dash_label(method, text = "-", options ={}, &block)
      update_options_with_class!(options, 'dash-label')
      label(method, text, options, &block)
    end

    def gender_select(method, options ={}, html_options ={})
      choices = @template.options_for_select([['male', 'm'], ['female', 'f']])
      select(method, choices, options, html_options)
    end

    def dob_select(method, options = {}, html_options = {})
      options[:order] = [:day, :month, :year]
      options[:start_year] = 18.years.ago.year
      options[:end_year] = 100.years.ago.year
      date_select(method, options, html_options)
    end

    def error_field(attribute, options = {})
      return unless object.errors[attribute]
      update_options_with_class!(options, 'text-danger')
      content = object.errors[attribute].first
      @template.content_tag(:div, content, options)
    end

    def help_text(method, content, options = {})
      @template.help_text(object, method, content, options)
    end

    def input_group(&block)
      @template.form_input_group(&block)
    end

    def checkbox(&block)
      @template.form_checkbox(&block)
    end

    def radio(&block)
      @template.form_radio(&block)
    end

    def submit(name, options ={})
      update_options_with_class!(options, 'btn btn-primary')
      super(name, options) << " " # add a space to the end
    end

    def cancel(path, edit_path = nil, options ={})
      options[:class] = Array(options[:class])
      options[:class] << "btn btn-default"
      options[:data] = { confirm: "Cancel without saving?"}

      if edit_path && object.persisted?
        path = edit_path
      end
      @template.link_to('cancel', path, options)
    end

    private

    def append_error_field_to_content!(content, method, options)
      unless object.errors[method].empty? || options[:error_field] == false
        content << error_field(method)
      end
      content
    end

    def update_options_with_form_control_class!(options)
      update_options_with_class!(options, 'form-control')
    end

    def update_options_with_class!(options, klass)
      @template.update_options_with_class!(options, klass)
    end

  end

  def help_text(object, method, content, options = {})
    return if object.errors[method].any?
    update_options_with_class!(options, 'help-block')
    content_tag(:small, content, options)
  end

  def kc_form(record, options = {}, &block)
    options.update(builder: KatanaCodeFormBuilder)
    form_for(record, options, &block)
  end

  def input_group(options={}, &block)
    content = capture(&block)
    update_options_with_class!(options, 'input-group')
    content_tag(:div, content, options)
  end

  def form_group(options ={}, &block)
    content = capture(&block)
    update_options_with_class!(options, 'form-group')
    content_tag(:div, content, options)
  end

  def form_fieldset(options={}, &block)
    update_options_with_class!(options, "fieldset")
    content_tag(:fieldset, capture(&block), options)
  end

  def form_legend(content={}, options ={})
    content_tag(:legend, content, options)
  end

  def form_input_group(&block)
    content_tag(:div, capture(&block), class: "input-group")
  end

  def form_checkbox(&block)
    content_tag(:div, capture(&block), class: "checkbox")
  end

  def form_radio(&block)
    content_tag(:div, capture(&block), class: "radio")
  end

  def options_for_sort_order
    options_for_select([['Ascending', "ASC"], ["Descending", "DESC"]])
  end

  def error_messages_for(object)
    if object.errors[:base].any?
      message = object.errors[:base].first
      %{<div class="text-danger">#{message}</div>}.html_safe
    end
  end

  def update_options_with_class!(options, new_class)
    options.tap { |hash| hash[:class] = Array(hash[:class]) << new_class }
  end

end