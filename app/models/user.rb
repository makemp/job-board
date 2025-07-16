class User < ApplicationRecord
  encrypts :email, deterministic: true, downcase: true
end
