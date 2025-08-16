require 'input_parser'

describe "input parser" do
  it "should fail on an invalid file" do
    expect { parse('no such file') }.to raise_error(Errno::ENOENT)
  end 
  
  context 'new lines' do
    it 'should handle files where items are one per line' do
      output = parse('./samples/newlines.txt')
      expect(output.count).to eq(2) 
    end
  end
  
  context 'commas' do 
    it 'should handle files where items are already comma separated' do
      output = parse('./samples/commas.txt')
      expect(output.count).to eq(3) 
    end
  end

  context 'conjunctions' do
    it 'should handle splitting items joined by conjunctions with oxford comma' do
      output = parse('./samples/conjunctions_oxford.txt')
      expect(output.count).to eq(4)
      expect(output[-1]).to eq('sparkling water')
    end

    it 'should handle splitting items joined by conjunctions with oxford comma' do
      output = parse('./samples/conjunctions.txt')
      expect(output.count).to eq(4)
      expect(output[-2]).to eq('flour')
      expect(output[-1]).to eq('sparkling water')
    end
  end
end