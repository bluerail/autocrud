module Autocrud
  module Helper
    module InstanceMethods
      #
      # Set various globals used by the crud views
      #
      # @param classname The class that the next view should be rendered for
      #      
      # This is also useful for rendering partials of multiple classes
      # in one view. Just call set_crud_class to select the correct
      # model before calling render_crud_view or render_crud_view_in
      #
      # Example:
      #
      # set_crud_class Person
      #
      def set_crud_class classname
        @crud_class = classname

        @plural = classname.to_s.pluralize.classify
        @singular = classname.to_s.singularize.classify

        @i18n_prefix = @singular.underscore.downcase                  
      end

      def class_exists?(class_name)
        ObjectSpace.each_object(Class) {|c| return true if c.to_s == class_name }
        false
      end
      
      def get_class(class_name)
        ObjectSpace.each_object(Class) {|c| return c if c.to_s == class_name }
      end
      
      #
      # Converts time in minutes to readable timestamp
      #
      # @param duration Integer time in minutes, e.g: 824
      # @return String Readable time, e.g: "13:44"
      #
    	def mtime(duration)
        hour = (duration.to_i / 60).to_s
        min = (duration.to_i % 60).to_s
  
        duration = hour.rjust(2) + ":" + min.rjust(2)
  
        return duration.gsub(/\ /,"0")
      end

      #
      # Returns key from params when available
      #
      # @param params [Hash|Array] Object possible containing key
      # @param key Mixed Key to retreive
      # @param default Mixed Value to return when key is not included within container (default = nil)
      # @return Mixed key or default value
      #
      # Example:
      #
      # >> param({:id => 1, :foo => :bar}, :id, 5)
      # => 1
      #
      # >> param({:id => 1, :foo => :bar}, "test")
      # => nil
      #
      # >> param({:id => 1, :foo => :bar}, "test", "not_found")
      # => "not_found"
      #
      def param(params, key, default = nil)
        return params[key] if (params.kind_of?(Hash) || params.kind_of?(Array)) && params.include?(key)
        return params[1][key] if params.kind_of?(Array) && params.length == 2 && params[1].kind_of?(Hash) && params[1].include?(key)
        return default
      end
      
      #
      # Places javascript include and stylesheet link tags for usage in HTML head
      #
      # @return String javascript_include_tag
      #
      def init_autocrud
        javascript_include_tag('../autocrud/javascripts/autocrud.js', :cache => '../autocrud/javascripts/all_cached')
      end

      #
      # Determines whether a column can be sorted
      #
      # @param crud_class Class Class to sort
      # @param params Hash Hash containing column information
      # @return boolean true when column can be sorted
      #
      # A column is sortable when the class attributes contain the
      # column itself or when specific sorting instructions are
      # given in the parameters (:sort)
      #
      # Example:
      #
      # >> attribute_sortable(User, {:name => 'name'})
      # => true
      #
      # >> attribute_sortable(User, {:name => 'foo'})
      # => false
      #
      # >> attribute_sortable(User, {:name => 'foo', :sort => { :include => :bar, :key => :id }})
      # => true
      #
      def attribute_sortable(crud_class, params)
        name = attribute_name(params)
        sort = param(params, :sort)

        name && (crud_class.new.attributes.include?(name.to_s) || sort)
      end
      
      #
      # Returns name of attribute
      #
      # @param Hash Column information
      # @return String Name of attribute
      #
      # Example:
      #
      # >> attribute_name({:name => 'name'})
      # => "name"
      #
      # >> attribute_name({:name => 'customer_id'})
      # => "customer"
      #
      def attribute_name(params)
        param(params, :name, '').to_s.gsub(/_id/,"")
      end

      #
      # Returns class of attribute
      #
      # @param Hash Column information
      # @return mixed Class of column or nil when indeterminable
      #
      # Example:
      #
      # >> attribute_class({:name => 'user'})
      # => User
      #
      # >> attribute_class({:name => 'foo'})
      # => nil
      #
      def attribute_class(column)
        begin
          eval(column[:name].to_s.classify)
        rescue
          nil
        end
      end
      
      #
      # Returns raw attribute value for item
      #
      # This value differs from item.attribute, since
      # it will try the response of attribute_name
      # first
      #
      # This method is used as last effort to create
      # displayable version of an attribute
      #
      # Example:
      #
      # >> item_raw_value(@user, {:name => 'username'})
      # => 'my username'
      #
      # >> item_raw_value(@user, {:name => 'company'})
      # => 'my company' (as returned by @user.company.to_s)
      #
      # >> item_raw_value(@user, {:name => 'company_id'})
      # => 'my company'
      #
      def item_raw_value(item, params)
        return h(item.send(attribute_name(params)) || '') if item.respond_to?(attribute_name(params)) # object.user
        return h(item.send(param(params, :name, '').to_s)) if item.respond_to?(param(params, :name, '')) # object.dummy_id
      end

      #
      # Returns displayable value of an attribute
      # used in a list
      #
      # Tries different approaches based upon type
      # of attribute, for example: a boolean attribute will
      # be displayed as an image
      #
      # Supported types:
      #
      # - boolean
      # - currency
      # - custom => uses a helper method named <object_name>_<attribute_name>_list_value(item) (something like user_full_name_list_value)
      # - date
      # - datetime
      # - paperclip, with additional paramter :size
      #
      # Falls back to item_raw_value
      #
      def attribute_list_value(params)
        column = param(params, :name)
        item = param(params, :item)

        if column && item
          type = param(params,:type,(item.attributes.include?(column.to_s) ? item.column_for_attribute(column).type : "other").to_s).to_s
          value = case type
            when 'boolean' then item.send(attribute_name(params)) ? image_tag("/autocrud/images/tick.png", :alt => t('true'), :title => t('true')) : image_tag("/autocrud/images/cross.png", :alt => t('false'), :title => t('false'))
            when 'custom' then send(@singular.underscore+"_"+column.to_s+"_list_value".to_s, item)
            when 'date' then item.send(attribute_name(params)) ? item.send(attribute_name(params)).strftime("%d-%m-%Y") : ""
            when 'datetime' then item.send(attribute_name(params)) ? l(item.send(attribute_name(params))) : ""
            when 'paperclip' then item.send(column.to_s+'?') ? image_tag(item.send(column.to_s, param(params, :size))) : ""
            when 'currency' then number_to_currency(item.send(attribute_name(params)).to_f, :format => "<span class='currency_show_symbol'>%u</span><span class='currency_show_value'>%n</span>")
            when 'percentage' then number_to_percentage(item.send(attribute_name(params)).to_f)
            when 'select' then 
              values = param(params,:select).collect{|element| element.is_a?(Array) && element.length == 2 ? element : [element.to_s, element.to_s]}.collect{|element| element[1] == item.send(attribute_name(params)).to_s ? element[0] : nil}.compact
              values.length > 0 ? values.first : item.send(attribute_name(params)).to_s
            else class_exists?('Lico::AutoCrud::Types::' + type.classify) ? get_class('Lico::AutoCrud::Types::' + type.classify).to_list_value(item, attribute_name(params)) : (item_raw_value(item, params) || "")
          end
          if display_link_to?(:show)
            return link_to(value, { :action => 'show', :id => item }, :class => 'dummy', :onclick => 'return crud_show(event,"' + url_for(:action => 'show', :id => item) + ', ' + item.id.to_s + '")')
          else
            return value
          end
        else
        	return ''
				end
      end

      #
      # Returns displayable value of an attribute
      # used when showing an object
      #
      # Tries different approaches based upon type
      # of attribute, for example: a boolean attribute will
      # be displayed as an image
      #
      # Supported types:
      #
      # - boolean
      # - currency
      # - custom => uses a helper method named <object_name>_<attribute_name>_list_value(item) (something like user_full_name_list_value)
      # - date
      # - datetime
      # - paperclip, with additional paramter :size
      #
      # Falls back to item_raw_value
      #
      def attribute_show_value(params)
        column = param(params, :name)
        item = param(params, :item)

        if column && item
          type = param(params,:type,(item.attributes.include?(column.to_s) ? item.column_for_attribute(column).type : "other").to_s).to_s
          return case type
            when 'boolean' then item.send(attribute_name(params)) ? t('true') : t('false')
            when 'custom' then send(@singular.underscore+"_"+column.to_s+"_show_value".to_s, item)
            when 'date' then item.send(attribute_name(params)) ? item.send(attribute_name(params)).strftime("%d-%m-%Y") : ""
            when 'datetime' then item.send(attribute_name(params)) ? l(item.send(attribute_name(params))) : ""
            when 'paperclip' then item.send(column.to_s+'?') ? image_tag(item.send(column.to_s, param(params, :size))) : "-"
            when 'currency' then number_to_currency(item.send(attribute_name(params)).to_f, :format => "<span class='currency_show_symbol'>%u</span><span class='currency_show_value'>%n</span>")
            when 'percentage' then number_to_percentage(item.send(attribute_name(params)).to_f)
            when 'ckeditor' then content_tag("span", item.send(attribute_name(params)), :class => 'ckdata')
            when 'select' then 
              values = param(params,:select).collect{|element| element.is_a?(Array) && element.length == 2 ? element : [element.to_s, element.to_s]}.collect{|element| element[1] == item.send(attribute_name(params)).to_s ? element[0] : nil}.compact
              values.length > 0 ? values.first : item.send(attribute_name(params)).to_s
            else class_exists?('Lico::AutoCrud::Types::' + type.classify) ? get_class('Lico::AutoCrud::Types::' + type.classify).to_show_value(item, attribute_name(params)) : (item_raw_value(item, params) || "")
          end
				else
        	return ''
				end
      end
      
      #
      # Returns weither to display a link to
      # a specified action
      #
      # By default links will be displayed for
      # [:new, :list, :edit, :destroy, :show]
      #
      # Prevent them by using:
      #
      # prohibit_link_to :new
      #
      def display_link_to?(action)
        @display_link.include?(action)
      end
      
      #
      # Creates a YUI button of the given name using a URL
      # created by the set of options. See the valid options
      # in the documentation for url_for. 
      #
      def crud_link_to(name, options = {}, html_options = nil)
        # content_tag("span",
        #   content_tag("span",
            link_to(name, options, html_options)
        #     ,
        #     :class => 'first-child'),
        #   :class => (html_options && html_options.include?(:class) ? html_options[:class] + " " : "") + "yui-button yui-link-button",
        #   :onmouseover => 'this.className = this.className + " yui-button-hover yui-link-button-hover"',
        #   :onmouseout => 'this.className = this.className.replace(/ yui-button-hover yui-link-button-hover/,"")',
        #   :id => (html_options && html_options.include?(:id) ? "crud_link_to_" + html_options[:id] : nil)
        # )
      end
      
      #
      # Creates a YUI button to a remote action defined by
      # options[:url] (using the url_for format) that‘s
      # called in the background using XMLHttpRequest.
      #
      # The result of that request can then be inserted into
      # a DOM object whose id can be specified with options[:update].
      # Usually, the result would be a partial prepared by
      # the controller with render :partial.
      #
      def crud_link_to_remote(name, options = {}, html_options = nil)
        # content_tag("span",
        #   content_tag("span",
            link_to_remote(name, options, html_options)#,
          #   :class => 'first-child'),
          # :class => (html_options && html_options.include?(:class) ? html_options[:class] + " " : "") + "yui-button yui-link-button",
          # :onmouseover => 'this.className = this.className + " yui-button-hover yui-link-button-hover"',
          # :onmouseout => 'this.className = this.className.replace(/ yui-button-hover yui-link-button-hover/,"")',
          # :id => (html_options && html_options.include?(:id) ? "crud_link_to_remote_" + html_options[:id] : nil)
        # )
      end
      
      #
      # Creates a YUI submit button with the text value as the caption.
      #
      def crud_submit_tag(value = "Save changes", options = {})
        submit_tag(value, options)
        # options.stringify_keys!
        # 
        # if disable_with = options.delete("disable_with")
        #   disable_with = "this.value='#{disable_with}'"
        #   disable_with << ";#{options.delete('onclick')}" if options['onclick']
        #   
        #   options["onclick"]  = "if (window.hiddenCommit) { window.hiddenCommit.setAttribute('value', this.value); }"
        #   options["onclick"] << "else { hiddenCommit = document.createElement('input');hiddenCommit.type = 'hidden';"
        #   options["onclick"] << "hiddenCommit.value = this.value;hiddenCommit.name = this.name;this.form.appendChild(hiddenCommit); }"
        #   options["onclick"] << "this.setAttribute('originalValue', this.value);this.disabled = true;#{disable_with};"
        #   options["onclick"] << "result = (this.form.onsubmit ? (this.form.onsubmit() ? this.form.submit() : false) : this.form.submit());"
        #   options["onclick"] << "if (result == false) { this.value = this.getAttribute('originalValue');this.disabled = false; }return result;"
        # end
        # 
        # if confirm = options.delete("confirm")
        #   options["onclick"] ||= 'return true;'
        #   options["onclick"] = "if (!#{confirm_javascript_function(confirm)}) return false; #{options['onclick']}"
        # end
        # 
        # options["type"] = "submit"
        # 
        # content_tag("span",
        #   content_tag("span",
        #     content_tag("button", value, options.stringify_keys),
        #     :class => 'first-child'),
        #   :class => "yui-button yui-submit-button",
        #   :onmouseover => 'this.className = "yui-button yui-submit-button yui-button-hover yui-submit-button-hover"',
        #   :onmouseout => 'this.className = "yui-button yui-submit-button"'
        # )
      end
      
      #
      # Renders form field for an attribute
      # used when creating or editing an object
      #
      # Tries different approaches based upon type
      # of attribute, for example: a boolean attribute will
      # be displayed as an image
      #
      # Supported types (as defined in lib/crued_views/form_fields):
      #
      # - boolean
      # - ckeditor
      # - country_select
      # - currency
      # - custom => uses a helper method named input_for_<object_name>_<attribute_name>_list_value(form, item) (something like input_for_user_full_name)
      #
      # Falls back to 'other'
      #
      def render_crud_form_field(column, item, locals)
        locals = locals.merge({:item => item, :column => column})

        if param(column,:grouped_select)
          return content_tag(
            "select",
            tag("option", :value => "") + grouped_options_for_select(param(column,:grouped_select), @item.send(column[:name])),
            :id => "#{@singular.underscore}_#{column[:name]}",
            :name => "#{@singular.underscore}[#{column[:name]}]"
          )
        elsif param(column,:select)
          locals[:f].select(column[:name].to_s, param(column,:select).collect {|element| element.is_a?(Array) && element.length == 2 ? element : [element.to_s, element.to_s]}, { :include_blank => true }.merge(param(column, :params, {})), param(column, :params, {}))
        else
          type = param(column, :type, (item.attributes.include?(column[:name].to_s) ? item.column_for_attribute(column[:name]).type : "other")).to_s
          type = 'other_record' if param(column, :type, '') == '' && item.respond_to?(column[:name].to_s+"_id") && (attribute_class(column).respond_to?(:find) || column.include?(:find_class))
          locals = locals.merge({:type => type})

          if class_exists?('Lico::AutoCrud::Types::' + type.classify)
            return get_class('Lico::AutoCrud::Types::' + type.classify).to_input(item, column[:name], locals[:f], locals[:params])
          end
          
          return case type.to_sym
          when :boolean then locals[:f].check_box(column[:name], :class => 'in_boolean')
          when :country_select then locals[:f].localized_country_select(
              column[:name].to_s,
              [:NL, :BE, :LU, :FR, :DE],
              { :include_blank => '' },
              param(column, :params, { }).merge({ :class => 'in_country_select' })
            )
          when :currency then number_to_currency(0, :format => "%u") + "&nbsp;".html_safe + locals[:f].text_field(column[:name], :class => 'in_currency', :style => 'text-align: right', :value => number_to_currency(@item.send(column[:name]).to_f, :separator => ".", :delimiter => "", :format => "%n"))
          when :custom then send("input_for_#{@singular.underscore}_#{column[:name].to_s}", locals[:f], item)
          when :date then locals[:f].date_select(column[:name], param(column, :options, {}),{ :class => 'in_date' })
          when :datetime then locals[:f].datetime_select(column[:name], :minute_step => 15, :class => 'in_datetime')
          when :file then locals[:f].file_field(column[:name], :class => 'in_file')
          when :hidden then locals[:f].hidden_field(column[:name], param(column, :params, { }).merge({:class => 'in_hidden'}))
          when :no_input then @item.send(column[:name])
          when :other_record then
            find_class = column.include?(:find_class) ? column[:find_class] : attribute_class(column)
            find_conditions = column[:ajax_select_conditions]
            find_items = find_class.find(:all, :select => param(column, :ajax_select, nil), :joins => param(column, :ajax_select_joins, []), :include => param(column, :ajax_select_include, []), :limit => 5, :conditions => find_conditions).collect do |element| 
              [ element.to_s, element.id ]
            end
            locals[:f].select("#{column[:name].to_s}_id", find_items, { :include_blank => true }.merge(param(column, :options, {})))
          when :paperclip then
            item.send(column[:name].to_s).nil? ? 
              # no image
              locals[:f].file_field(column[:name], :class => 'in_paperclip') :

              # with image
              image_tag(item.send(column[:name].to_s, param(column, :size))) +
              content_tag(
                "div", 
                t('paperclip.upload_new') + " " + locals[:f].file_field(column[:name], :class => 'in_paperclip') +
                content_tag(
                  "div",
                  locals[:f].check_box("#{column[:name]}_delete") +
                  locals[:f].label("#{column[:name]}_delete", t('paperclip.select_unlink'))
                )
              )
          when :password then locals[:f].password_field(column[:name], :class => 'in_password')
          when :select then locals[:f].select(column[:name].to_s, param(column,:select).collect {|element| element.is_a?(Array) && element.length == 2 ? element : [element.to_s, element.to_s]}, { :include_blank => true }.merge(param(column, :params, {})), param(column, :params, {}))
          when :textarea then locals[:f].text_area(column[:name], param(column, :params, { }).merge({:class => 'in_textarea'}))
          else
            locals[:f].text_field(column[:name], param(column, :params, { }).merge({:class => 'in_' + type}))
          end
        end
      end
      
      
      def crud_form_error_messages(form)
        count = form.object.errors.count
        
        unless count.zero?
          html = {}
          [:id, :class].each do |key|
              html[key] = 'errorExplanation'
          end

          # options[:object_name] ||= params.first

          I18n.with_options :locale => params[:locale], :scope => [:activerecord, :errors, :template] do |locale|
            object_name = form.object_name.to_s
            object_name = I18n.t(object_name, :default => object_name.gsub('_', ' '), :scope => [:activerecord, :models], :count => 1)
            header_message = locale.t :header, :count => count, :model => object_name

            message = locale.t(:body)

            error_messages = form.object.errors.full_messages.map {|msg| content_tag(:li, ERB::Util.html_escape(msg)) }.join.html_safe

            contents = ''
            contents << content_tag(:h2, header_message) unless header_message.blank?
            contents << content_tag(:p, message) unless message.blank?
            contents << content_tag(:ul, error_messages)

            content_tag(:div, contents.html_safe, html)
          end
        else
          ''
        end          
      end

      #
      # Renders content like Rails' built-in render method. The only difference
      # with render_crud view is the locations used to find view or partial
      #
      # Locations used:
      #
      # 1) Controller.view_paths
      # 2) Custom locations (@see append_view_path)
      # 3) lico_aud_crud view paths
      # 4) built-in render method
      #
      def render_crud_view(options = nil, locals = {}, &block)
        c = case self.class.to_s
          when "ActionView::Base" then controller
          else self
        end
        
        #
        # Try view paths of controller
        #
        c.view_paths.each do |view_path|
          crud_views_in(File.join(view_path, c.controller_path), options).each do |view|
            return render_crud_view_in(view, options, locals, &block)
          end
        end
        
        #
        # Try custom view paths
        #
        @custom_view_paths.each do |view_path|
          crud_views_in(File.join(view_path, c.controller_path), options).each do |view|
            return render_crud_view_in(view, options, locals, &block)
          end
        end
        
        #
        # Try plugin built in (app/views/autocrud) view path
        #
        crud_views_in(@view_path, options).each do |view|
          return render_crud_view_in(view, options, locals, &block)
        end
        
        #
        # Rescue using Rails's built in render method
        #
        return render(options, locals, &block)
      end
      
      def crud_views_in(view_path, options)
        case options
        when Hash
          if options.key?(:partial)
            partial_name = /\// =~ options[:partial] ? options[:partial].gsub(/\/([^\/]*)/,"/_\\1") : "_" + options[:partial]
            Dir[File.join(view_path, partial_name) + ".*"]
          else
            [] # unsupported
          end
        when String
          Dir[File.join(view_path, options) + ".*"]
        else
          [] # unsupported
        end
      end
      
      def render_crud_view_in(view, options, locals, &block)
        case options
        when Hash
          if options.key?(:partial)
            options.delete(:partial)
            options[:file] = view
            return render(options, locals, &block)
          else
            [] # unsupported
          end
        when String
          return render(view, locals, &block)
        else
          [] # unsupported
        end
      end
    end
  end
end