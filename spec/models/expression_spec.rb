require 'rails_helper'

RSpec.describe Expression do
  describe '.of' do
    context 'raise exception when argument is not OR/AND' do
      it { expect { Expression.of('nor') }.to raise_error 'Unknown Expression nor' }
    end

    context 'return an or expression when argument is not AND' do
      it { expect(Expression.of('or')).to be_a(Expressions::OrExpression) }
    end

    context 'return an and expression when argument is AND' do
      it { expect(Expression.of('and')).to be_a(Expressions::AndExpression) }
    end
  end

  describe '.from_xlsform_relevant' do
    context 'single expression mode' do
      let(:relevant_attr) { "${q1}='no' or ${q2}='yes'" }
      let(:or_expression) { Expressions::OrExpression.new }

      before(:each) do
        allow(Expression).to receive(:of).with(Expression::EXPRESSION_OR).and_return(or_expression)
      end

      it 'should call append_conditions of expression' do
        expect(or_expression).to receive(:append_conditions!).once

        Expression.from_xlsform_relevant relevant_attr
      end
    end

    context 'multi expression mode' do
      let(:relevant_attr) { "${q1}='no' or ${q2}='yes' and ${q3}='no'" }

      before(:each) do
        allow(Expression).to receive(:has_multiple_mode?).with(relevant_attr).and_return(true)
      end

      it 'should raise exception when there is using multiple conjunction(AND & OR)' do
        expect { Expression.from_xlsform_relevant(relevant_attr) }.to raise_error 'Question is supported only a single expression(OR or AND)'
      end
    end
  end

  describe '#append_conditions!' do
    let(:relevant_attr) { "${q1}='no' or ${q2}='yes'" }
    let(:or_expression) { Expressions::OrExpression.new }

    it 'should call parse relevant attributes to expression' do
      expect(Parsers::ConditionParser).to receive(:parse).with("${q1}='no'")
      expect(Parsers::ConditionParser).to receive(:parse).with("${q2}='yes'")

      or_expression.append_conditions! relevant_attr
    end
  end

end
