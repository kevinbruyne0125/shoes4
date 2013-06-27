require 'spec/shoes/spec_helper'

main_object = self

describe Shoes::Font do

  before :each do
    @font = Shoes::Font.new("Helvetica")
  end

  after :each do
    FileUtils.remove_file(Shoes::FONT_DIR + "Tahoma.ttf", :force => true)
    FileUtils.remove_file(Shoes::FONT_DIR + "Impact.ttf", :force => true)
    FileUtils.remove_file(Shoes::FONT_DIR + "Arial Black.ttf", :force => true)
  end

  it 'is not nil' do
    @font.should_not be_nil
  end

  it 'saves path passed in to path attribute' do
    @font.path.should == "Helvetica"
  end

  describe 'fonts_from_dir' do
    it 'returns a hash of font names and paths from the dir passed in' do
      Shoes::Font.fonts_from_dir(Shoes::FONT_DIR).should be_a(Hash)
    end
  end

  describe 'system_font_dirs' do
    it 'returns the path to the systems font directory' do
      #Shoes::Font.system_font_dirs.should == ["/System/Library/Fonts/", "/Library/Fonts/" ]
    end
  end

  describe 'parse_filename_from_path' do
    it 'returns name of file with extension' do
      path = Shoes::FONT_DIR + "Coolvetica.ttf"
      parse_filename_from_path(path).should == "Coolvetica.ttf"
    end
  end

  describe '#find_font' do
    it 'checks if the font is currently available' do
      @font.should_receive :available?
      @font.find_font
    end

    it 'checks if available font is in font folder' do
      pending "need to reimplement after changes"
    end
  end

  describe '#available?' do
    it 'returns true if font is in Shoes::FONTS array' do
      @cool_font = Shoes::Font.new("Coolvetica")
      @cool_font.available?.should == true
    end

    it 'returns false if font is not in Shoes::FONTS array' do
      @lost_font = Shoes::Font.new("Knights Who Say Not Here")
      @lost_font.available?.should == false
    end
  end

  describe '#in_folder?' do
    it 'returns false if font is not in folder' do
      @font.in_folder?.should == false
    end

    it 'returns true if font is allready in folder' do
      @in_folder_font = Shoes::Font.new("Coolvetica")
      @in_folder_font.in_folder?.should == true
    end
  end

  describe '#load_font_from_system' do
    it 'returns false if it fails to load the font' do
      Shoes::FONTS << "Knights Who Say Ni"
      @lost_font = Shoes::Font.new("Knights Who Say Ni")
      @lost_font.found?.should == false
    end

    it 'copies file from system to font dir' do
      #Shoes::Font.fonts_from_dir(Shoes::FONT_DIR).include?("Arial Black").should == false
      #@new_font = Shoes::Font.new("Arial Black")
      #Shoes::Font.fonts_from_dir(Shoes::FONT_DIR).include?("Arial Black").should == true
    end
  end

  describe "#copy_file_to_font_folder" do
    it 'copies file from path passed in to the font dir' do
      #Shoes::Font.fonts_from_dir(Shoes::FONT_DIR).include?("Tahoma").should == false
      #@blank_font = Shoes::Font.new("")
      #@blank_font.copy_file_to_font_folder("/Library/Fonts/Tahoma.ttf")
      #Shoes::Font.fonts_from_dir(Shoes::FONT_DIR).include?("Tahoma").should == true

    end
  end
end






