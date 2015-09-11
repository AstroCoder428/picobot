require_relative 'spec_helper'

describe Picobot do
  it 'should move to the far right corner' do
    arena = Picobot::Arena.new(9, 9)
    rules = <<EOM
0 *x** -> E 0
0 *E*x -> S 0
EOM
    sm = Picobot::StateMachine.new(arena, rules, 2, 3, log: true)
    sm.run
    expect(sm.bot.x).to eq 9
    expect(sm.bot.y).to eq 9
  end
end
