#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module WorkPackages
      module Form
        class WorkPackagePayloadRepresenter < Roar::Decorator
          include Roar::JSON::HAL
          include Roar::Hypermedia

        class << self
          alias_method :original_new, :new

          # we can't use a factory method as we sometimes rely on ROAR instantiating representers
          # for us. Thus we override the :new method.
          # This allows adding instance specific properties to our representer.
          def new(work_package, options = {})
            klass = Class.new(WorkPackagePayloadRepresenter)
            injector = ::API::V3::Utilities::CustomFieldInjector.new(klass)
            work_package.available_custom_fields.each do |custom_field|
              injector.inject_value(custom_field)
            end

            klass.original_new(work_package, options)
          end
        end

          self.as_strategy = ::API::Utilities::CamelCasingStrategy.new

          def initialize(represented, options = {})
            if options[:enforce_lock_version_validation]
              # enforces availibility validation of lock_version
              represented.lock_version = nil
            end

            super(represented)
          end

          property :_type, exec_context: :decorator, writeable: false

          property :linked_resources,
                   as: :_links,
                   exec_context: :decorator,
                   getter: -> (*) {
                     work_package_attribute_links_representer represented
                   },
                   setter: -> (value, *) {
                     representer = work_package_attribute_links_representer represented
                     representer.from_json(value.to_json)
                   }

          property :lock_version
          property :subject, render_nil: true
          property :description,
                   exec_context: :decorator,
                   getter: -> (*) {
                     {
                       format: 'textile',
                       raw: represented.description,
                       html: description_renderer.to_html
                     }
                   },
                   setter: -> (value, *) { represented.description = value['raw'] },
                   render_nil: true
          property :parent_id, writeable: true

          property :project_id,
                   getter: -> (*) { nil },
                   render_nil: false

          property :start_date,
                   exec_context: :decorator,
                   getter: -> (*) {
                     datetime_formatter.format_date(represented.start_date, allow_nil: true)
                   },
                   setter: -> (value, *) {
                     represented.start_date = datetime_formatter.parse_date(value,
                                                                            'startDate',
                                                                            allow_nil: true)
                   },
                   render_nil: true
          property :due_date,
                   exec_context: :decorator,
                   getter: -> (*) {
                     datetime_formatter.format_date(represented.due_date, allow_nil: true)
                   },
                   setter: -> (value, *) {
                     represented.due_date = datetime_formatter.parse_date(value,
                                                                          'dueDate',
                                                                          allow_nil: true)
                   },
                   render_nil: true
          property :version_id,
                   getter: -> (*) { nil },
                   setter: -> (value, *) { self.fixed_version_id = value },
                   render_nil: false
          property :created_at,
                   getter: -> (*) { nil }, render_nil: false
          property :updated_at,
                   getter: -> (*) { nil }, render_nil: false

          def _type
            'WorkPackage'
          end

          private

          def datetime_formatter
            API::V3::Utilities::DateTimeFormatter
          end

          def work_package_attribute_links_representer(represented)
            ::API::V3::WorkPackages::Form::WorkPackageAttributeLinksRepresenter.new represented
          end

          def description_renderer
            ::API::Utilities::Renderer::TextileRenderer.new(represented.description, represented)
          end
        end
      end
    end
  end
end
