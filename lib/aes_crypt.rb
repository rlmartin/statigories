require 'openssl'

module AESCrypt
  # Decrypts a block of data (encrypted_data) given an encryption key
  # and an initialization vector (iv).  Keys, iv's, and the data 
  # returned are all binary strings.  Cipher_type should be
  # "AES-256-CBC", "AES-256-ECB", or any of the cipher types
  # supported by OpenSSL.  Pass nil for the iv if the encryption type
  # doesn't use iv's (like ECB).
  #:return: => String
  #:arg: encrypted_data => String 
  #:arg: key => String
  #:arg: iv => String
  #:arg: cipher_type => String
  def AESCrypt.decrypt_full(encrypted_data, key, iv, cipher_type)
    aes = OpenSSL::Cipher::Cipher.new(cipher_type)
    aes.decrypt
    aes.key = key
    aes.iv = iv if iv != nil
		begin
	    aes.update(encrypted_data) + aes.final
		rescue Exception => e
			''
		end
  end
  def AESCrypt.decrypt(encrypted_data)
		AESCrypt.decrypt_full(encrypted_data, "sffhgju334sws45y6jtaasw44sdsde6648ddjdl323wewe", nil, "AES-256-ECB")
	end
  
  # Encrypts a block of data given an encryption key and an 
  # initialization vector (iv).  Keys, iv's, and the data returned 
  # are all binary strings.  Cipher_type should be "AES-256-CBC",
  # "AES-256-ECB", or any of the cipher types supported by OpenSSL.  
  # Pass nil for the iv if the encryption type doesn't use iv's (like
  # ECB).
  #:return: => String
  #:arg: data => String 
  #:arg: key => String
  #:arg: iv => String
  #:arg: cipher_type => String  
  def AESCrypt.encrypt_full(data, key, iv, cipher_type)
    aes = OpenSSL::Cipher::Cipher.new(cipher_type)
    aes.encrypt
    aes.key = key
    aes.iv = iv if iv != nil
		begin
	    aes.update(data) + aes.final      
		rescue Exception => e
			''
		end
  end
  def AESCrypt.encrypt(encrypted_data)
		AESCrypt.encrypt_full(encrypted_data, "sffhgju334sws45y6jtaasw44sdsde6648ddjdl323wewe", nil, "AES-256-ECB")
	end
end
