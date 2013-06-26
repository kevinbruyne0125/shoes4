module Shoes
  FONT_DIR = DIR + "/fonts/"

  class Font
    FONT_TYPES = "{ttf,ttc,otf,fnt,fon,bdf,pcf,snf,mmm,pfb,pfm}"
    attr_reader :path
    # TODO-refactor this to have better names for methods and variables

    def self.fonts_from_dir(path)
      font_names_and_paths = {}
      Dir.glob(path + "*." + FONT_TYPES).each do |font_file|
        font_names_and_paths[remove_file_ext(parse_filename_from_path(font_file))] = font_file
      end
      font_names_and_paths
    end

    def self.system_font_dirs
      case RbConfig::CONFIG['host_os']
        # these may need to be "darwin*" and "linux*" etc
        when "darwin"
          return ["/System/Library/Fonts/", "/Library/Fonts/" ]
        when "linux" "linux-gnu"
          return ["/usr/share/fonts/" , "/usr/local/share/fonts/", "~/.fonts/"]
        when "mswin" "windows"
          return ["/Windows/Fonts/"]
      end
      # TODO- this should probably have a default
      ''
    end

    def self.add_font_names_to_fonts_constant
      Shoes::FONTS.clear
      Shoes::FONTS << fonts_from_dir(FONT_DIR).keys
      system_font_dirs.each do |dir|
        Shoes::FONTS << fonts_from_dir(dir).keys
      end
      Shoes::FONTS.flatten!
    end

    def self.parse_filename_from_path(file_path)
      # TODO-put this method back together again
      name = Pathname.new(file_path)
      basename = name.basename
      basenamestring = basename.to_s
    end

    def self.remove_file_ext(file_name)
      file_name[0...-4]
    end

    def initialize(path = '')
      # TODO-need to work on return value from what is called in builins
      # TODO-check for font name or path here
      @path = path
      Shoes::Font.add_font_names_to_fonts_constant
      @found = find_font
    end

    def find_font
      return false unless available?
      return true if in_folder?
      load_font_from_system
    end

    def available?
      FONTS.include? @path
    end

    def in_folder?
      Shoes::Font.fonts_from_dir(FONT_DIR).include? @path
    end

    # TODO-refactor to pull something out of this it is too big
    def load_font_from_system
      fonts_hash = {}
      Shoes::Font.system_font_dirs.each do |dir|
        fonts = Shoes::Font.fonts_from_dir(dir)
        #puts fonts.inspect
        fonts_hash.merge!(fonts)
      end
      copy_file_to_font_folder(fonts_hash.fetch(@path))
    end

    # TODO-do something with comp value that is returned
    def copy_file_to_font_folder(file_path)
      new_file_path = Shoes::FONT_DIR + Shoes::Font.parse_filename_from_path(file_path)
      FileUtils.cp(file_path, Shoes::FONT_DIR)
      FileUtils.cmp(file_path, new_file_path)
    end

    def found?
      @found
    end

    #TODO-Do something about this so it integrates with other test
    def font_name
      return @font_name unless @path == ''
      DEFAULT_TEXTBLOCK_FONT
    end
  end
end


__END__
# FONTS constant -
# get all files from fonts folder and add names to FONTS array
# this should also include all fonts available to you from the local platform
# get all files from system font folder and add names to FONTS array
#
#
# according to PragTob this method is used to load fonts
# and it should receive a path to the font that needs to be loaded
# this font should probably be copied into the fonts folder
# HacketyHack had the fonts dir as a global HH::FONTS
# should add a global SHOES::FONTS or something
#
# this should be added in the lib/shoes/dsl.rb
# as it is a DSL method
#
# there is a fonts folder that maybe should be checked for existing fonts
# then if not in the folder then load from path passed into methad
#OS X stores fonts in /System/Library/Fonts/
#Windows stores fonts in /Windows/Fonts/
#Linux use fc-match @font to find path to font
#can check RUBY_PLATFORM
#/mingw/
#/darwin/
