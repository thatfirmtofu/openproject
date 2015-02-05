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

require 'spec_helper'
require 'ostruct'

describe SettingsHelper, type: :helper do
  include Capybara::RSpecMatchers

  shared_examples_for 'labelled' do
    it { is_expected.to have_selector 'label' }
  end

  describe '#setting_select' do
    before do
      expect(Setting).to receive(:field).and_return('2')
    end

    subject(:output) {
      helper.setting_select :field, [['Popsickle', '1'], ['Jello', '2'], ['Ice Cream', '3']]
    }

    it_behaves_like 'labelled'

    it 'should output element' do
      expect(output).to have_selector 'select > option', count: 3
      expect(output).to have_select 'settings_field', selected: 'Jello'
    end
  end

  describe '#setting_multiselect' do
    before do
      expect(Setting).to receive(:field).at_least(:once).and_return('1')
    end

    subject(:output) {
      helper.setting_multiselect :field, [['Popsickle', '1'], ['Jello', '2'], ['Ice Cream', '3']]
    }

    it 'should have three labels' do
      expect(output).to have_selector 'label.block', count: 3
    end

    it 'should output element' do
      expect(output).to have_selector 'input[type="checkbox"]', count: 3
    end
  end

  describe '#settings_multiselect' do
    before do
      expect(Setting).to receive(:field_a).at_least(:once).and_return('2')
      expect(Setting).to receive(:field_b).at_least(:once).and_return('3')
    end

    subject(:output) {
      helper.settings_multiselect [:field_a, :field_b], [
        ['Popsickle', '1'], ['Jello', '2'], ['Ice Cream', '3']
      ]
    }

    it 'should output element' do
      expect(output).to have_selector 'table'
      expect(output).to have_checked_field 'field_a_2'
      expect(output).to have_checked_field 'field_b_3'
    end
  end

  describe '#setting_text_field' do
    before do
      expect(Setting).to receive(:field).and_return('important value')
    end

    subject(:output) {
      helper.setting_text_field :field
    }

    it_behaves_like 'labelled'

    it 'should output element' do
      expect(output).to include %{
        <input id="settings_field" name="settings[field]" type="text" value="important value" />
      }.strip
    end
  end

  describe '#setting_text_area' do
    before do
      expect(Setting).to receive(:field).and_return('important text')
    end

    subject(:output) {
      helper.setting_text_area :field
    }

    it_behaves_like 'labelled'

    it 'should output element' do
      expect(output).to include %{
        <textarea id="settings_field" name="settings[field]">
important text</textarea>
      }.strip
    end
  end

  describe '#setting_check_box' do
    subject(:output) {
      helper.setting_check_box :field
    }

    context 'when setting is true' do
      before do
        expect(Setting).to receive(:field?).and_return(true)
      end

      it_behaves_like 'labelled'

      it 'should output element' do
        expect(output).to have_selector 'input[type="checkbox"]'
        expect(output).to have_checked_field 'settings_field'
      end
    end

    context 'when setting is false' do
      before do
        expect(Setting).to receive(:field?).and_return(false)
      end

      it_behaves_like 'labelled'

      it 'should output element' do
        expect(output).to have_selector 'input[type="checkbox"]'
        expect(output).to have_unchecked_field 'settings_field'
      end
    end
  end

  describe '#setting_label' do
    subject(:output) {
      helper.setting_label :field
    }

    it_behaves_like 'labelled'
  end

  describe '#notification_field' do
    before do
      expect(Setting).to receive(:notified_events).and_return(%w(interesting_stuff))
    end

    subject(:output) {
      helper.notification_field(notifiable)
    }

    context 'when setting includes option' do
      let(:notifiable) { OpenStruct.new(name: 'interesting_stuff') }

      it_behaves_like 'labelled'

      it 'should output element' do
        expect(output).to have_selector 'input[type="checkbox"]'
        expect(output).to have_checked_field 'Interesting stuff'
      end
    end

    context 'when setting does not include option' do
      let(:notifiable) { OpenStruct.new(name: 'boring_stuff') }

      it_behaves_like 'labelled'

      it 'should output element' do
        expect(output).to have_selector 'input[type="checkbox"]'
        expect(output).to have_unchecked_field 'Boring stuff'
      end
    end
  end
end