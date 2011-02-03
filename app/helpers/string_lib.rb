module StringLib
  POINT_REGEXP = /^([\(\[{]?(\d+|\d+.\d+|.\d+)?\s*,\s*(\d+|\d+.\d+|.\d+)[\)\]}]?)$/

  def self.cast(strValue, symType)
    if (symType == nil) or (symType == ''): symType = :s end
    symType = self.to_sym(symType)
    strValue = strValue.to_s
    case symType
			when :b, :bool, :boolean: strValue.match(/^(true|t|yes|y|1)$/i) != nil
      when :date, :datetime: self.to_date(strValue)
      when :dec, :decimal: strValue.to_d
      when :float, :f, :dbl, :d, :double: strValue.to_f
      when :int, :i, :integer: strValue.to_i
      when :point_x, :point_y:
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
      when :sym, :symbol: strValue.to_sym
      when :time, :t: self.to_time(strValue)
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
    if (symType == nil) or (symType == ''): symType = :s end
    symType = self.to_sym(symType)
    origValue = strValue
    strValue = strValue.to_s
    case symType
      when :dec, :decimal, :float, :f, :dbl, :d, :double, :int, :i, :integer:
        if self.left(strValue, 1) == '+': strValue = self.right(strValue, strValue.length - 1) end
        bolIsNegative = false
        if self.left(strValue, 1) == '-'
          strValue = self.right(strValue, strValue.length - 1)
          bolIsNegative = true
        end
        if self.left(strValue, 1) == '0' and strValue.length > 1: strValue = self.ltrim(strValue, '0') end
        if self.left(strValue, 1) == '.': strValue = '0' + strValue end
        if bolIsNegative
          strValue = '-' + strValue
        end
        iLen = strValue.length
        strValue = self.rtrim(strValue, '0')
        if iLen > 0 and strValue.length == 0: strValue = '0' end
        if self.right(strValue, 1) == '.': strValue = self.left(strValue, strValue.length - 1) end
    end
    case symType
			when :b, :bool, :boolean: strValue.match(/^(true|t|yes|y|1|false|f|no|n|0)$/i) != nil
      when :date, :datetime: self.to_date(strValue) != nil
      when :dec, :decimal: (strValue.to_d.to_s == strValue) or (strValue.to_i.to_s == strValue)
      when :float, :f, :dbl, :d, :double: (strValue.to_f.to_s == strValue) or (strValue.to_i.to_s == strValue)
      when :int, :i, :integer: strValue.to_i.to_s == strValue
      when :point: strValue.match(self::POINT_REGEXP) != nil
      when :sym, :symbol: strValue.to_sym === origValue
      when :time, :t: self.to_time(strValue) != nil
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
    unless iNumChars >= strValue.length: strValue.slice!(iNumChars, (strValue.length - iNumChars)) end
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

  def self.right(strValue, iNumChars)
    if iNumChars < strValue.length
      strValue.slice((strValue.length - iNumChars), iNumChars)
    else
      strValue
    end
  end
  def self.right!(strValue, iNumChars)
    unless iNumChars >= strValue.length: strValue.slice!(0, (strValue.length - iNumChars)) end
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

  def self.to_date_only(str)
    arr = ParseDate.parsedate(str.to_s)
    if (arr[0] != nil) and (arr[1] != nil) and (arr[2] != nil) and Date.valid_civil?(*arr[0..2])
      Date.civil(*arr[0..2])
    else
      nil
    end
  end

  def self.to_date(str)
    arr = ParseDate.parsedate(str.to_s)
    if (arr[0] != nil) and (arr[1] != nil) and (arr[2] != nil) and (arr[3] != nil) and (arr[4] != nil) and (arr[5] != nil) and Date.valid_civil?(*arr[0..2]) and Date.valid_time?(*arr[3..5])
      DateTime.civil(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], (arr[6] == nil ? '' : arr[6]))
    elsif (arr[0] != nil) and (arr[1] != nil) and (arr[2] != nil) and (arr[3] != nil) and (arr[4] != nil) and Date.valid_civil?(*arr[0..2]) and Date.valid_time?(arr[3], arr[4], 0)
      DateTime.civil(arr[0], arr[1], arr[2], arr[3], arr[4], 0, (arr[6] == nil ? '' : arr[6]))
    elsif (arr[0] != nil) and (arr[1] != nil) and (arr[2] != nil) and Date.valid_civil?(*arr[0..2])
      DateTime.civil(arr[0], arr[1], arr[2], 0, 0, 0, (arr[6] == nil ? '' : arr[6]))
    else
      self.to_time(str)
    end
  end

  def self.to_time(str)
    arr = ParseDate.parsedate(str.to_s)
    if (arr[3] != nil) and (arr[4] != nil) and (arr[5] != nil) and Date.valid_time?(*arr[3..5])
      DateTime.civil(0, 1, 1, arr[3], arr[4], arr[5], (arr[6] == nil ? '' : arr[6]))
    elsif (arr[3] != nil) and (arr[4] != nil) and Date.valid_time?(arr[3], arr[4], 0)
      DateTime.civil(0, 1, 1, arr[3], arr[4], 0, (arr[6] == nil ? '' : arr[6]))
    else
      nil
    end
  end

  def self.to_sym(str)
    str.to_s.gsub(/\W+/, '_').downcase.to_sym
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
