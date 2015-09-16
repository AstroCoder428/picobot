require_relative 'spec_helper'

describe Picobot::Bot do
  it 'should have an x and y coordinate' do
    arena = Picobot::Arena.new(5, 10)
    bot = Picobot::Bot.new(arena, 2, 3)
    expect(bot.x).to eq 2
    expect(bot.y).to eq 3
  end

  it 'should start off in an unfinished state' do
    arena = Picobot::Arena.new(5, 10)
    bot = Picobot::Bot.new(arena, 2, 3)
    expect(bot.done).to be false
  end

  it 'should start off in state 0' do
    arena = Picobot::Arena.new(5, 10)
    bot = Picobot::Bot.new(arena, 2, 3)
    expect(bot.state).to eq 0
  end

  it 'should be able to move' do
    arena = Picobot::Arena.new(5, 10)
    bot = Picobot::Bot.new(arena, 2, 4)
    expect { bot.move(0, -1) }.not_to raise_exception
    expect(bot.x).to eq 2
    expect(bot.y).to eq 3
  end
end
