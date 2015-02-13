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

module API
  module Decorators
    class Schema < Single
      def self.schema(property,
                      type: nil,
                      title: nil,
                      required: true,
                      writable: true,
                      min_length: nil,
                      max_length: nil)
        raise ArgumentError if property.nil? || type.nil?

        title = I18n.t("#{i18n_prefix}.#{property}") unless title

        schema = ::API::Decorators::PropertySchemaRepresenter.new(type: type,
                                                                  name: title)
        schema.required = required
        schema.writable = writable
        schema.min_length = min_length if min_length
        schema.max_length = max_length if max_length

        property property,
                 getter: -> (*) { schema },
                 writeable: false
      end

      def self.schema_with_allowed_link(property,
                                        type: nil,
                                        title: nil,
                                        href_callback: nil,
                                        required: true,
                                        writable: true)
        raise ArgumentError if property.nil? || href_callback.nil?

        type = property.to_s.camelize unless type
        title = I18n.t("#{i18n_prefix}.#{property}") unless title

        property property,
                 exec_context: :decorator,
                 getter: -> (*) {
                   representer = ::API::Decorators::AllowedValuesByLinkRepresenter.new(
                     type: type,
                     name: title)
                   representer.required = required
                   representer.writable = writable

                   if represented.defines_assignable_values?
                     representer.allowed_values_href = instance_eval(&href_callback)
                   end

                   representer
                 }
      end

      def self.i18n_prefix
      end
    end
  end
end
