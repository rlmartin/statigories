module StringLib
  def self.cast(strValue, symType)
    if (symType == nil) or (symType == ''): symType = :s end
    symType = self.to_sym(symType)
    strValue = strValue.to_s
    case symType
      when :date, :datetime: Date.parse(strValue)
      when :dec, :decimal: strValue.to_d
      when :float, :f, :dbl, :d, :double: strValue.to_f
      when :int, :i, :integer: strValue.to_i
      when :sym, :symbol: strValue.to_sym
      when :time, :t: Time.parse(strValue)
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

  def self.to_const_name(name)
      name.gsub(/\W+/, '_').upcase
  end
  def self.to_const_name!(name)
      name.gsub!(/\W+/, '_').upcase!
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
  
  def self.url_has_protocol(strValue)
    strValue.match(/^(((http|https|ftp):\/\/)|\/)/i)
  end
end
