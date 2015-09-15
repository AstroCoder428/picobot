require_relative 'spec_helper'

describe Picobot::Arena do
  it 'should have proper size attributes' do
    arena = Picobot::Arena.new(5, 10)
    expect(arena.max_x).to eq 5
    expect(arena.max_y).to eq 10
  end

  it 'should start off with all areas untouched' do
    arena = Picobot::Arena.new(5, 10)
    6.times do |x|
      11.times do |y|
        expect(arena.touched?(x, y)).to eq false
      end
    end
  end

  it 'should not start off as finished' do
    arena = Picobot::Arena.new(5, 10)
    expect(arena.finished?).to eq false
  end

  it 'should not be finished if only some areas are touched' do
    arena = Picobot::Arena.new(5, 10)
    arena.touch(1, 2)
    arena.touch(3, 4)
    expect(arena.finished?).to eq false
  end

  it 'should be finished if all areas are touched' do
    arena = Picobot::Arena.new(5, 10)
    6.times do |x|
      11.times do |y|
        expect(arena.finished?).to eq false
        arena.touch(x, y)
      end
    end
    expect(arena.finished?).to eq true
  end

  it 'should include points within the arena' do
    arena = Picobot::Arena.new(5, 10)
    expect(arena.include?(0, 0)).to eq true
    expect(arena.include?(5, 0)).to eq true
    expect(arena.include?(0, 10)).to eq true
    expect(arena.include?(5, 10)).to eq true
    expect(arena.include?(2, 3)).to eq true
  end

  it 'should not include points outside the arena' do
    arena = Picobot::Arena.new(5, 10)
    expect(arena.include?(-1, 0)).to eq false
    expect(arena.include?(5, 20)).to eq false
    expect(arena.include?(5, -1)).to eq false
    expect(arena.include?(40, 3)).to eq false
    expect(arena.include?(-6, 200)).to eq false
  end

  it 'should be able to block squares with obstacles' do
    arena = Picobot::Arena.new(5, 10)
    arena.block(2, 3)
    expect(arena.blocked?(2, 3)).to eq true
  end

  it 'should not have blocked squares by default' do
    arena = Picobot::Arena.new(5, 10)
    6.times do |x|
      11.times do |y|
        expect(arena.blocked?(x, y)).to eq false
      end
    end
  end

  it 'should identify bounds correctly' do
    arena = Picobot::Arena.new(10, 10)
    arena.block(0, 1)
    expect(arena.bounds(0, 0)).to eq({ n: true, s: true, e: false, w: true })
    expect(arena.bounds(5, 6)).to eq({ n: false, s: false, e: false, w: false })
  end
end
