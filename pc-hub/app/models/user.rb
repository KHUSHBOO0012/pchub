class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :invitable,
    :recoverable, :rememberable, :trackable, :validatable, :validate_on_invite => true
        
    validates :name, presence: true
    validates :country, presence: true
    validates :city, presence: true
    validates :email, confirmation: true
    validates :role, presence: true

    if self.created_by_invite == true
        validate :inviter_has_permission_to_invite
    end

    def self.search(search)
      where("name LIKE ?", "%#{search}%") 
    end
   
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

    private

    def inviter_has_permission_to_invite
        inviter = User.find(self.invited_by_id)

        if self.role == "superadmin"
            unless inviter.role == "superadmin"
                raise CanCan::AccessDenied
            end
        end

        if inviter.role == "admin"
            unless self.role == "staff" || self.role == "volunteer"
                raise CanCan::AccessDenied
            end
        end

        if inviter.role == "staff" || inviter.role == "volunteer"
            raise CanCan::AccessDenied
        end
    end
end
