require_relative 'spec_helper'

describe Picobot::RuleParser do
  def format_rules(arr)
    arr.map { |r| "#{r}\n" }.join('')
  end

  it 'should round-trip simple rules' do
    rules = <<EOM
0 *x** -> E 0
0 *E*x -> S 0
EOM
    parser = Picobot::RuleParser.new
    res = nil
    expect { res = parser.parse(rules) }.not_to raise_exception
    expect(format_rules(res)).to eq rules
  end

  it 'should complain about identical rules' do
    rules = <<EOM
0 *x** -> E 0
0 *x** -> E 0
EOM
    parser = Picobot::RuleParser.new
    expect { parser.parse(rules) }.to raise_exception Picobot::RuleConflictError
  end

  it 'should complain about overlapping rules' do
    rules = <<EOM
0 *x** -> E 0
0 **x* -> S 0
EOM
    parser = Picobot::RuleParser.new
    expect { parser.parse(rules) }.to raise_exception Picobot::RuleConflictError
  end

  it 'should match rules correctly' do
    rules = <<EOM
0 *x** -> E 0
EOM
    parser = Picobot::RuleParser.new
    res = nil
    expect { res = parser.parse(rules) }.not_to raise_exception
    r = res[0]
    expect(r.match?(0, true, false, true, true)).to be true
    expect(r.match?(0, false, false, true, true)).to be true
    expect(r.match?(0, true, true, true, true)).to be false
    expect(r.match?(2, true, false, true, true)).to be false
  end
end
