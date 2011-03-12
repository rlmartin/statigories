require 'chronic'

module StringLib
  POINT_REGEXP = /^([\(\[{]?(\d+|\d+.\d+|.\d+)?\s*,\s*(\d+|\d+.\d+|.\d+)[\)\]}]?)$/

  def self.cast(strValue, symType)
    symType = :s if (symType == nil) or (symType == '')
    symType = self.to_sym(symType)
    strValue = strValue.to_s
    case symType
			when :b, :bool, :boolean then strValue.match(/^(true|t|yes|y|1)$/i) != nil
      when :date then self.to_date(strValue)
      when :datetime then self.to_datetime(strValue)
      when :dec, :decimal then strValue.to_d
      when :float, :f, :dbl, :d, :double then strValue.to_f
      when :int, :i, :integer then strValue.to_i
      when :point_x, :point_y
        arrMatches = strValue.match(self::POINT_REGEXP)
        if arrMatches.length >= 3
          if symType == :point_x
            self.cast(arrMatches[2], :dec)
          else
            self.cast(arrMatches[3], :dec)
          end
        else
          strValue
        end
      when :sym, :symbol then strValue.to_sym
      when :time, :t then self.to_time(strValue)
      else strValue
    end
  end

  def self.empty?(strValue)
    ((strValue == nil) or (strValue == ''))
  end

  def self.escape_reg_exp(strValue)
    strValue.gsub(/(\/|\.|\*|\+|\?|\||\(|\)|\[|\]|\{|\}|\\|\^|\$)/, '\\\\\1')
  end

  def self.escape_reg_exp!(strValue)
    strValue.gsub!(/(\/|\.|\*|\+|\?|\||\(|\)|\[|\]|\{|\}|\\|\^|\$)/, '\\\\\1')
  end

  def self.is?(pValue, symType)
    strValue = pValue
    symType = :s if (symType == nil) or (symType == '')
    symType = self.to_sym(symType)
    origValue = strValue
    strValue = strValue.to_s
    case symType
      when :dec, :decimal, :float, :f, :dbl, :d, :double, :int, :i, :integer
        strValue = self.right(strValue, strValue.length - 1) if self.left(strValue, 1) == '+'
        bolIsNegative = false
        if self.left(strValue, 1) == '-'
          strValue = self.right(strValue, strValue.length - 1)
          bolIsNegative = true
        end
        strValue = self.ltrim(strValue, '0') if self.left(strValue, 1) == '0' and strValue.length > 1
        strValue = '0' + strValue if self.left(strValue, 1) == '.'
        if bolIsNegative
          strValue = '-' + strValue
        end
        iLen = strValue.length
        strValue = self.rtrim(strValue, '0')
        strValue = '0' if iLen > 0 and strValue.length == 0
        strValue = self.left(strValue, strValue.length - 1) if self.right(strValue, 1) == '.'
    end
    case symType
			when :b, :bool, :boolean then strValue.match(/^(true|t|yes|y|1|false|f|no|n|0)$/i) != nil
      when :date, :datetime then self.parse_date(strValue) != nil
      when :dec, :decimal then (strValue.to_d.to_s == strValue) or (strValue.to_i.to_s == strValue)
      when :float, :f, :dbl, :d, :double then (strValue.to_f.to_s == strValue) or (strValue.to_i.to_s == strValue)
      when :int, :i, :integer then strValue.to_i.to_s == strValue
      when :point then strValue.match(self::POINT_REGEXP) != nil
      when :sym, :symbol then strValue.to_sym === origValue
      when :time, :t then self.to_time(strValue) != nil
      else false
    end
  end

  def self.is_bool?(strValue)
    self.is?(strValue, :bool)
  end

  def self.is_date?(strValue)
    self.is?(strValue, :date)
  end

  def self.is_float?(strValue)
    self.is?(strValue, :float)
  end

  def self.is_int?(strValue)
    self.is?(strValue, :int)
  end

  def self.is_point?(strValue)
    self.is?(strValue, :point)
  end

  def self.is_sym?(strValue)
    self.is?(strValue, :sym)
  end

  def self.is_time?(strValue)
    self.is?(strValue, :time)
  end

  def self.left(strValue, iNumChars)
    if iNumChars < strValue.length
      strValue.slice(0, iNumChars)
    else
      strValue
    end
  end
  def self.left!(strValue, iNumChars)
    strValue.slice!(iNumChars, (strValue.length - iNumChars)) unless iNumChars >= strValue.length
  end

  def self.left_of(strValue, strFind)
    strValue.partition(strFind)[0]
  end

  def self.left_of_rev(strValue, strFind)
    arr = strValue.rpartition(strFind)
    if arr[0] == '' and arr[1] == ''
      strValue
    else
      arr[0]
    end
  end

  def self.ltrim(strValue, strChar = " ")
    strValue.sub(Regexp.new("^#{escape_reg_exp(strChar)}+"), "")
  end
  def self.ltrim!(strValue, strChar = " ")
    strValue.sub!(Regexp.new("^#{escape_reg_exp(strChar)}+"), "")
  end

  def self.MD5(strValue)
    Digest::MD5.hexdigest(strValue)
  end

  def self.parse_date(strValue)
    # Note: this generally ignores ST vs DT and uses the date instead. For example, if EST is given for a EDT date, EDT will be used (and vice versa).
    # This could be confusing, but I don't think people generally make a distinction between the two (or know which is which) anyway.
    dtDate = nil
    strTZ = self.right_of_rev(self.trim(strValue), ' ')
    unless strTZ == strValue or strTZ.downcase == 'am' or strTZ.downcase == 'pm'
      objTZInfo = self.to_timezone(strTZ)
      if objTZInfo
        objOldTZ = Chronic.time_class
        Chronic.time_class = ActiveSupport::TimeZone.create(objTZInfo.current_period.abbreviation, objTZInfo.current_period.utc_offset, objTZInfo)
        dtDate = Chronic.parse(self.translate_datetime(self.left_of_rev(self.trim(strValue), ' ')), :guess => false)
        Chronic.time_class = objOldTZ if objTZInfo
      end
    end
    dtDate = Chronic.parse(self.translate_datetime(strValue), :guess => false) if dtDate == nil
    dtDate = dtDate.first unless dtDate == nil
    dtDate
  end

  def self.right(strValue, iNumChars)
    if iNumChars < strValue.length
      strValue.slice((strValue.length - iNumChars), iNumChars)
    else
      strValue
    end
  end
  def self.right!(strValue, iNumChars)
    strValue.slice!(0, (strValue.length - iNumChars)) unless iNumChars >= strValue.length
  end

  def self.right_of(strValue, strFind)
    arr = strValue.partition(strFind)
    if arr[1] == '' and arr[2] == ''
      strValue
    else
      arr[2]
    end
  end

  def self.right_of_rev(strValue, strFind)
    strValue.rpartition(strFind)[2]
  end

  def self.rtrim(strValue, strChar = " ")
    strValue.sub(Regexp.new("#{escape_reg_exp(strChar)}+$"), "")
  end
  def self.rtrim!(strValue, strChar = " ")
    strValue.sub!(Regexp.new("#{escape_reg_exp(strChar)}+$"), "")
  end

  def self.to_const_name(name)
      name.gsub(/\W+/, '_').upcase
  end
  def self.to_const_name!(name)
      name.gsub!(/\W+/, '_').upcase!
  end

  def self.to_date(str)
    d = self.parse_date(str.to_s)
    if (d != nil) and Date.valid_civil?(d.year, d.month, d.day)
      Date.civil(d.year, d.month, d.day)
    else
      nil
    end
  end

  def self.to_datetime(str)
    self.parse_date(str)
  end

  def self.to_time(str)
    d = self.parse_date(str.to_s)
    unless d == nil
      DateTime.civil(0, 1, 1, d.hour, d.min, d.sec, d.utc_offset.to_f / 86400)
    else
      nil
    end
  end

  def self.to_timezone(str, strRegion = nil)
    objTZ = nil
    strIdentifier = str.to_s.downcase
    unless TZINFO_IDENTIFIERS.include?(strIdentifier)
      if strRegion
        strRegion = strRegion.to_s.downcase
        strRegion = nil unless TIMEZONE_LIST[strRegion]
      end
      if strRegion and TIMEZONE_LIST[strRegion][strIdentifier]
        strIdentifier = TIMEZONE_LIST[strRegion][strIdentifier]
      else
        strIdentifier = TIMEZONE_LIST['default'][strIdentifier]
      end
      strIdentifier = strIdentifier['identifier'] if strIdentifier
    end
    objTZ = TZInfo::Timezone.get(TZInfo::Timezone.all_identifiers[TZINFO_IDENTIFIERS.index(strIdentifier.downcase)]) if strIdentifier and TZINFO_IDENTIFIERS.include?(strIdentifier.downcase)
    objTZ
  end

  def self.to_sym(str)
    str.to_s.gsub(/\W+/, '_').downcase.to_sym
  end

  def self.translate_datetime(str)
    strResult = nil
    strResult = DATETIME_TRANSLATION[str.downcase] if DATETIME_TRANSLATION[str.downcase]
    strResult = str unless strResult
    strResult
  end

  def self.trim(strValue, strChar = " ")
    strValue.sub(Regexp.new("^#{escape_reg_exp(strChar)}+"), "").sub(Regexp.new("#{escape_reg_exp(strChar)}+$"), "")
  end
  def self.trim!(strValue, strChar = " ")
    strValue.sub!(Regexp.new("^#{escape_reg_exp(strChar)}+"), "")
    strValue.sub!(Regexp.new("#{escape_reg_exp(strChar)}+$"), "")
  end

  def self.url_decode(str)
    CGI::unescape(str)
  end
  
  def self.url_encode(str)
    CGI::escape(str)
  end
  
  def self.url_has_protocol(strValue)
    strValue.match(/^(((http|https|ftp):\/\/)|\/)/i)
  end
end
