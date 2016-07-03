class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
    validates :name, presence: true
    validates :country, presence: true
    validates :city, presence: true
    validates :email, confirmation: true
   
    def role?(role)
        return self.role == role.to_s
    end

    def active_for_authentication?
        if self.role? :admin
            self.approved = super && approved? 
        else
            self.approved = true
        end
    end

    def inactive_message 
        if !approved? 
            :not_approved 
        else 
            super 
        end 
    end
end
