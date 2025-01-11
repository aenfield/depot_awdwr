class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_secure_password
  after_destroy :ensure_an_admin_user_remains # if this raises an exception, the transaction with the destroy won't complete and the destroy won't happen

  class Error < StandardError
  end

  private
    def ensure_an_admin_user_remains
      if User.count.zero?
        raise Error.new "Can't delete last user"
      end
    end
end
