class SuperAdmin < ApplicationRecord
  include DeviseInvitable::Inviter

  devise :authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
end
