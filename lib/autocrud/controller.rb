module Autocrud
  module Controller
    module ClassMethods
      #
      # Initializes Autocrud
      #
      def acts_as_autocrud
        class_eval do
          include Autocrud::Controller::InstanceMethods
          
          before_filter :detect_autocrud_options
        end
      end
      
      def acts_as_auto_crud
        ActiveSupport::Deprecation.warn "Use acts_as_autocrud instead of acts_as_auto_crud", caller
        acts_as_autocrud
      end
    end
    
    module InstanceMethods
      include Autocrud::Helper::InstanceMethods

      #
      # Loads up method autocrud_options if created in controller
      # and tries to determine class to use
      #
      def detect_autocrud_options
        #
        # 1) set default options 
        #
        begin
          crud_class eval(self.controller_name.singularize.classify) if @crud_class.nil?
        rescue
        end
        
        @page_size = 15
        
        @display_link = [:new, :list, :edit, :destroy, :show]
        
        @layout = 'application' # Warning: this overrides anything set in the controller
        
        #
        # 2) Let method autocrud_options override default options
        #
        if self.respond_to?("auto_crud_options")
          ActiveSupport::Deprecation.warn "Use autocrud_options in your controller instead of auto_crud_options"
          auto_crud_options
        end
        
        autocrud_options if self.respond_to?("autocrud_options")
      end
      
      #
      # Loads up autocrud_options from other controller
      # to inherit custom options
      #
      def inherit_from(controller_class)
        inherit_object = controller_class.new
        inherit_object.class_eval do |c|
          require __FILE__
          include Autocrud::Controller::InstanceMethods
        end
        inherit_object.send(:detect_autocrud_options)
        inherit_object.send(:autocrud_options)

        inherit_object.instance_variable_get(:@create_options).each do |key, value|
          @create_options[key] = value
        end
        inherit_object.instance_variable_get(:@edit_options).each do |key, value|
          @edit_options[key] = value
        end
        inherit_object.instance_variable_get(:@show_options).each do |key, value|
          @show_options[key] = value
        end
        inherit_object.instance_variable_get(:@list_options).each do |key, value|
          @list_options[key] = value
        end
        
        @edit_columns = inherit_object.instance_variable_get(:@edit_columns)
        @show_columns = inherit_object.instance_variable_get(:@show_columns)
        @create_columns = inherit_object.instance_variable_get(:@create_columns)
        @list_columns = inherit_object.instance_variable_get(:@list_columns)
      end
      
      def prohibit_link_to(action)
        if action.is_a?(Array)
          @display_link = @display_link - action
        else
          @display_link = @display_link - [action]
        end
      end
      
      #
      # Sets class to use for crud
      #
      def crud_class(classname)
        set_crud_class(classname)

        @view_path = File.join(File.dirname(__FILE__), "..", "..", "app", "views", "autocrud")
        @custom_view_paths = []
        
        @create_options = { }
        @edit_options = { }
        @show_options = { }
        @list_options = { }

        @column_descriptions = {}
        @object_description = ""
      end
      
      def column_description(column, label)
        @column_descriptions[column] = label
      end
      
      def object_description(new_description)
        @object_description = new_description
      end

      def set_options(options)
        options[:create].each do |key, value|
          @create_options[key] = value
        end if options.include?(:create)
        options[:edit].each do |key, value|
          @edit_options[key] = value
        end if options.include?(:edit)
        options[:show].each do |key, value|
          @show_options[key] = value
        end if options.include?(:show)
        options[:list].each do |key, value|
          @list_options[key] = value
        end if options.include?(:list)
        
        if @create_options.include?(:submit_multipart) && @create_options[:submit_multipart] == true
          @create_options[:pre_submit] = (@create_options.include?(:pre_submit) ? @create_options[:pre_submit] : "") + "crud_do_iframe_submit();"
        end
        if @edit_options.include?(:submit_multipart) && @edit_options[:submit_multipart] == true
          @edit_options[:pre_submit] = (@edit_options.include?(:pre_submit) ? @edit_options[:pre_submit] : "") + "crud_do_iframe_submit();"
        end
      end
      
      #
      # Sets column structure for lists
      #
      def columns(columns)
        list_columns(columns) 
        show_columns(columns) 
        create_columns(columns) 
        edit_columns(columns) 
      end
      def list_columns(columns)
        @list_columns = Hash.new
        columns = columns.sort { |a,b| (a[1][:order].to_s + "_" + a[0].to_s) <=> (b[1][:order].to_s + "_" + b[0].to_s)  }
        columns.each do |column|
          @list_columns[@list_columns.length] = column[1].merge({:name => column[0]}) unless param(column, :type, "").to_s == 'spacer'
        end
      end
      def show_columns(columns)
        @show_columns = Hash.new
        columns = columns.sort { |a,b| (a[1][:order].to_s + "_" + a[0].to_s) <=> (b[1][:order].to_s + "_" + b[0].to_s)  }
        columns.each do |column|
          @show_columns[@show_columns.length] = column[1].merge({:name => column[0]})
        end
      end
      def create_columns(columns)
        @create_columns = Hash.new
        columns = columns.sort { |a,b| (a[1][:order].to_s + "_" + a[0].to_s) <=> (b[1][:order].to_s + "_" + b[0].to_s)  }
        columns.each do |column|
          @create_columns[@create_columns.length] = column[1].merge({:name => column[0]})
        end
      end
      def edit_columns(columns)
        @edit_columns = Hash.new
        columns = columns.sort { |a,b| (a[1][:order].to_s + "_" + a[0].to_s) <=> (b[1][:order].to_s + "_" + b[0].to_s)  }
        columns.each do |column|
          @edit_columns[@edit_columns.length] = column[1].merge({:name => column[0]})
        end
      end
      def create_and_edit_columns(columns)
        create_columns(columns)
        edit_columns(columns)
      end
      def list_and_show_columns(columns)
        list_columns(columns)
        show_columns(columns)
      end
      
      #
      # e.g.: append_view_path File.join(RAILS_ROOT,"app","views","admin","gastouders")
      #
      def append_view_path(path)
        @custom_view_paths.push path
      end
      
      def index
        #
        # Determines columns to use in list unless
        # already specified using list_columns method
        #
        if @list_columns.nil?
          @list_columns = Hash.new
          @crud_class.new.attributes.each do |attribute|
            if /_id/ =~ attribute[0]
              @list_columns[@list_columns.length] = Hash[ :name => attribute[0].gsub(/_id/,"").to_sym, :sort => { :key => attribute[0].to_sym } ] unless ["created_at","updated_at"].include?(attribute[0])
            else
              @list_columns[@list_columns.length] = Hash[ :name => attribute[0].gsub(/_id/,"").to_sym ] unless ["created_at","updated_at"].include?(attribute[0])
            end
          end
        end

        #
        # Always sort using something...
        #
        if !params.include?(:sort)
          @list_columns.each do |key, column|
            if column[:default_order_by] && [:asc, :desc].include?(column[:default_order_by])
              params[:sort] = column[:name]
              params[:dir] = column[:default_order_by].to_s
            end
          end
          params[:sort] = @list_columns[0][:name].to_s unless params[:sort]
          params[:dir] = 'asc' unless params[:dir]
        end

        find_order = nil
        find_include = nil
        find_join = nil

        #
        # Sort using :key in @list_columns
        #
        @list_columns.each do |key, column|
          if param(column, :name).to_s == param(params, :sort).to_s
            if param(column, :sort)
              sort = param(column, :sort)
              if param(sort, :in)
                find_order = param(sort, :in).to_s.pluralize + "." + param(sort, :key).to_s + " " + params[:dir]
              else
                find_order = param(sort, :key).to_s + " " + params[:dir]
              end
              find_include = param(sort, :include)
              find_join = param(sort, :join)
            else
              find_order = @crud_class.table_name.to_s+"."+param(column, :name).to_s + " " + params[:dir]
              @list_columns[key][:sort] = Hash.new
            end

            @list_columns[key][:sort][:sorted] = param(params,:sort)
            @list_columns[key][:sort][:dir] = param(params,:dir)
          end
        end
        
        if find_include
          find_include = [find_include]
        else
          find_include = Array.new
        end

        if find_join
          find_join = [find_join]
        else
          find_join = Array.new
        end

        if param(@list_options,:find_include).is_a?(Array)
          param(@list_options,:find_include).each do |extra_include|
            find_include.push extra_include
          end
        elsif param(@list_options,:find_include)
          find_include.push param(@list_options,:find_include)
        end

        if param(@list_options,:find_join).is_a?(Array)
          param(@list_options,:find_join).each do |extra_include|
            find_join.push extra_include
          end
        elsif param(@list_options,:find_join)
          find_join.push param(@list_options,:find_join)
        end
        
        if params.include?(:query)
          columns = Array.new
          @list_columns.each do |key, column|
            if param(column, :filterable, true)
              if column.include?(:filter)
                filterparam = param(column, :filter)
                if param(filterparam, :key).is_a?(Array)
                  param(filterparam, :key).each do |k|
                    columns.push k.to_s + ' LIKE ?'
                  end
                else
                  columns.push param(filterparam, :key).to_s + ' LIKE ?' if param(filterparam, :key)
                end
                find_include.push param(filterparam, :include) if param(filterparam, :include)
                find_join.push param(filterparam, :join) if param(filterparam, :join)
              elsif param(column, :sort)
                sort = param(column, :sort)
                if param(sort, :in)
                  columns.push param(sort, :in).to_s.pluralize + "." + param(sort, :key).to_s + ' LIKE ?'
                elsif param(sort, :key)
                  columns.push param(sort, :key).to_s + ' LIKE ?'
                else
                  columns.push @crud_class.table_name.to_s+"."+param(column, :name).to_s + ' LIKE ?'
                end
                find_include.push param(sort, :include) if param(sort, :include)
                find_join.push param(sort, :join) if param(sort, :join)
              else
                columns.push @crud_class.table_name.to_s+"."+param(column, :name).to_s + ' LIKE ?'
              end
            end
          end

          if param(@list_options,:find_conditions).nil?
            @list_options[:find_conditions] = Array.new
            @list_options[:find_conditions][0] = ""
          else
            if @list_options[:find_conditions].is_a?(Array)
              @list_options[:find_conditions][0] = "(" + @list_options[:find_conditions][0] + ")"
            else
              first = "(" + @list_options[:find_conditions] + ")"
              @list_options[:find_conditions] = Array.new
              @list_options[:find_conditions][0] = first
            end
          end
          params[:query].split.each do |phrase|
            @list_options[:find_conditions][0] += " AND " if @list_options[:find_conditions][0] != ""
            @list_options[:find_conditions][0] += "(" + columns.join(" OR ") + ")"
            columns.each do |c|
              @list_options[:find_conditions].push "%" + phrase.to_s + "%"
            end
          end
        end

        find_include = find_include[0] if find_include.length == 1
        find_join = find_join[0] if find_join.length == 1
        
				#
				# The application can supply a custom selector (as a lambda) for cases where ActiveRecord::Base#find is insufficient
				# If no custom_find is supplied, a find statement is constructed
				#
				if param(@list_options,:custom_find)
					@items = param(@list_options, :custom_find).call({:order => find_order, :joins => find_join, :include => find_include, :conditions => param(@list_options,:find_conditions)})
					@item_count = @items.length
          @num_of_pages = (@item_count.to_f / @page_size.to_f).ceil
        	@page = [[1,@num_of_pages].max,[1,params[:page].to_i || 1].max].min
					@items = @items[(@page_size * (@page -1))..((@page_size * (@page -1))+@page_size-1)]
				else
          params[:scope] = @list_options[:default_named_scope].to_s if !params.include?(:scope) && param(@list_options, :default_named_scope)

					crud_scope = @crud_class
				  crud_scope = @crud_class.send(params[:scope]) if params.include?(:scope) && params[:scope] != "" && (param(@list_options, :default_named_scope) == params[:scope].to_sym || param(@list_options, :named_scopes, []).include?(params[:scope].to_sym))

          @item_count = crud_scope.count(:all, :conditions => param(@list_options,:find_conditions), :joins => find_join, :include => find_include)
          @num_of_pages = (@item_count.to_f / @page_size.to_f).ceil
          @page = [[1,@num_of_pages].max,[1,params[:page].to_i || 1].max].min
          @items = crud_scope.find(:all, :conditions => param(@list_options,:find_conditions), :joins => find_join, :include => find_include, :order => find_order, :limit => @page_size, :offset => @page_size * (@page - 1))
				end

        #
        # Appends column information with names
        # and sortable information
        #
        @list_columns.each do |key, column|
          @list_columns[key][:key] = attribute_name(column)
          @list_columns[key][:label] = t 'activerecord.attributes.' + @singular.downcase + '.' + attribute_name(column)
          @list_columns[key][:sortable] = param(column, :sortable, (attribute_sortable(@crud_class, column) ? "true" : "false"))
        end

        respond_to do |format|
          format.html {
            if request.xhr?
              if params.include?(:nested_list) && params.delete(:nested_list)
                render_crud_view 'index', :layout => false
              else
                render_crud_view :partial => 'autocrud/list', :locals => { :params => params, :page => @page, :num_of_pages => @num_of_pages, :items => @items, :list_options => @list_options, :list_columns => @list_columns }, :layout => false
              end
            else
              render_crud_view 'index', :layout => @layout
            end
          }
          format.xml { }
        end
      end

      #
      # Use specified layout for rendering
      #
      # Default: application
      #
      # TODO: Check is this is (still) necessary
      #
      def use_layout(target_layout)
        @layout = target_layout.to_s
      end
            
      def show
        @item = @crud_class.find(params[:id])

        #
        # Fetches set of attributes from class when not already specified
        #
        if @show_columns.nil?
          @show_columns = Hash.new
          @crud_class.new.attributes.each do |attribute|
            @show_columns[@show_columns.length] = Hash[ :name => attribute[0].gsub(/_id/,"").to_sym ] unless ["created_at","updated_at"].include?(attribute[0])
          end
        end

        respond_to do |format|
          format.html {
            if request.xhr?
              render_crud_view 'show', :layout => false
            else
              render_crud_view 'show', :layout => @layout
            end
          }
          format.xml  { render :xml => @item }
        end
      end

      def set_create_columns
        #
        # Fetches set of attributes from class when not already specified
        #
        if @create_columns.nil?
          @create_columns = Hash.new
          @crud_class.new.attributes.each do |attribute|
            @create_columns[@create_columns.length] = Hash[ :name => attribute[0].gsub(/_id/,"").to_sym ] unless ["created_at","updated_at"].include?(attribute[0])
          end
        end
      end

      def set_edit_columns
        #
        # Fetches set of attributes from class when not already specified
        #
        if @edit_columns.nil?
          @edit_columns = Hash.new
          @crud_class.new.attributes.each do |attribute|
            @edit_columns[@edit_columns.length] = Hash[ :name => attribute[0].gsub(/_id/,"").to_sym ] unless ["created_at","updated_at"].include?(attribute[0])
          end
        end
      end

      def new
        set_create_columns

        @item = @crud_class.new

        if request.xhr?
          render_crud_view 'new', :layout => false
        else
          render_crud_view 'new', :layout => @layout
        end
      end

      def create
        set_create_columns

        params_for_mass_assignment = params[@singular.underscore.to_sym.to_s.downcase].dup
        @create_columns.each do |key, column|
          if param(column,:allow_mass_assignment,true) == false
            params_for_mass_assignment.delete(param(column, :name).to_s)
            params_for_mass_assignment.delete(param(column, :name).to_s + "_id")
            (1..6).each do |num|
              params_for_mass_assignment.delete(param(column, :name).to_s+"(" + num.to_s + "i)")
            end
          end
        end

        @item = @crud_class.new(params_for_mass_assignment)
        @create_columns.each do |key, column|
          if param(column,:allow_mass_assignment,true) == false
            if params[@singular.underscore.to_sym.to_s.downcase].include?(param(column,:name))
              @item.send(param(column,:name).to_s+"=", params[@singular.underscore.to_sym.to_s.downcase][param(column,:name)])
            elsif params[@singular.underscore.to_sym.to_s.downcase].include?(param(column,:name).to_s + "_id")
              @item.send(param(column,:name).to_s+"_id=", params[@singular.underscore.to_sym.to_s.downcase][param(column,:name).to_s + "_id"])
            else
              has_partial_params = false
              param_value = ""
              (1..6).each do |part|
                param_part = (param(column,:name).to_s+"("+part.to_s+"i)").to_sym
                if params[@singular.underscore.to_sym.to_s.downcase].include?(param_part)
                  has_partial_params = true
                  param_value += params[@singular.underscore.to_sym.to_s.downcase][param_part]
                end
                
                param_value += "-"
              end
              @item.send(param(column,:name).to_s+"=", param_value) if has_partial_params
            end
          end
        end
        
        @item = self.before_create(@item, params) if self.respond_to?(:before_create)
        
        if @item.save
          return if self.respond_to?(:after_create) && self.after_create(@item, params)
          
          if request.xhr?
            render :text => "OK"
          else
            redirect_to :action => "index"
          end
        else
          set_create_columns
          if request.xhr?
            render_crud_view 'new', :layout => false
          else
            render_crud_view 'new', :layout => @layout
          end
        end
      end

      def edit
        set_edit_columns

        @item = @crud_class.find params[:id]

        if request.xhr?
          render_crud_view 'edit', :layout => false
        else
          render_crud_view 'edit', :layout => @layout
        end
      end

      def update
        set_edit_columns
        @item = @crud_class.find(params[:id])

        params_for_mass_assignment = params.include?(@singular.underscore.to_sym.to_s.downcase) ? params[@singular.underscore.to_sym.to_s.downcase].dup : Hash.new
        @edit_columns.each do |key, column|
          if param(column,:allow_mass_assignment,true) == false
            params_for_mass_assignment.delete(param(column, :name).to_s)
            params_for_mass_assignment.delete(param(column, :name).to_s + "_id")
            (1..6).each do |num|
              params_for_mass_assignment.delete(param(column, :name).to_s+"(" + num.to_s + "i)")
            end
          end
        end
        
        @item = self.before_update(@item, params) if self.respond_to?(:before_update)

        if @item.attributes = params_for_mass_assignment
          @edit_columns.each do |key, column|
            if param(column,:allow_mass_assignment,true) == false
              if params[@singular.underscore.to_sym.to_s.downcase].include?(param(column,:name))
                @item.send(param(column,:name).to_s+"=", params[@singular.underscore.to_sym.to_s.downcase][param(column,:name)])
              elsif params[@singular.underscore.to_sym.to_s.downcase].include?(param(column,:name).to_s + "_id")
                @item.send(param(column,:name).to_s+"_id=", params[@singular.underscore.to_sym.to_s.downcase][param(column,:name).to_s + "_id"])
              else
                has_partial_params = false
                param_value = ""
                (1..6).each do |part|
                  param_part = (param(column,:name).to_s+"("+part.to_s+"i)").to_sym
                  if params[@singular.underscore.to_sym.to_s.downcase].include?(param_part)
                    has_partial_params = true
                    param_value += params[@singular.underscore.to_sym.to_s.downcase][param_part]
                  end
                  
                  param_value += "-"
                end
                @item.send(param(column,:name).to_s+"=", param_value) if has_partial_params
              end
            end
          end

          if @item.valid? && @item.save
            return if self.respond_to?(:after_update) && self.after_update(@item, params)

            if request.xhr?
              render :text => "OK"
            else
              redirect_to :action => "show", :id => @item
            end
          else
            set_create_columns
            if request.xhr?
              render_crud_view 'edit', :layout => false
            else
              render_crud_view 'edit', :layout => @layout
            end
          end
        else
          set_create_columns
          if request.xhr?
            render_crud_view 'edit', :layout => false
          else
            render_crud_view 'edit', :layout => @layout
          end
        end
      end

      def destroy
        @item = @crud_class.find(params[:id])
        @item.destroy
        if request.xhr?
          render :text => "OK"
        else
          redirect_to :action => "index"
        end
      end
      
    end
  end
end