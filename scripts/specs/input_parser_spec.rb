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
      expect(output.count).to eq(2) 
    end
  end
end