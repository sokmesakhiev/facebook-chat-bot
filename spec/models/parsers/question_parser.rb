require 'rails_helper'

RSpec.describe Parsers::QuestionParser do
  context '.parse' do
    context 'text questionnaire' do
      let(:type) { :text }

      it { expect(Parsers::QuestionParser.parse(type)).to be_a_kind_of(Questions::TextQuestion) }
    end

    context 'integer questionnaire' do
      let(:type) { :integer }

      it { expect(Parsers::QuestionParser.parse(type)).to be_a_kind_of(Questions::IntegerQuestion) }
    end

    context 'decimal questionnaire' do
      let(:type) { :decimal }

      it { expect(Parsers::QuestionParser.parse(type)).to be_a_kind_of(Questions::DecimalQuestion) }
    end

    context 'date questionnaire' do
      let(:type) { :date }

      it { expect(Parsers::QuestionParser.parse(type)).to be_a_kind_of(Questions::DateQuestion) }
    end

    context 'select_one questionnaire' do
      let(:type) { :select_one }

      it { expect(Parsers::QuestionParser.parse(type)).to be_a_kind_of(Questions::SelectOneQuestion) }
    end

    context 'select_multiple questionnaire' do
      let(:type) { :select_multiple }

      it { expect(Parsers::QuestionParser.parse(type)).to be_a_kind_of(Questions::SelectMultipleQuestion) }
    end

    context 'unknown media questionnaire' do
      let(:type) { :media }

      it { expect { Parsers::QuestionParser.parse(type) }.to raise_error(StandardError, /Unknown datatype/) }
    end
  end

end
