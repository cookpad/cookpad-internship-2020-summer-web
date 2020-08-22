class UserUpdateForm
  include ActiveModel::Validations

  attr_accessor :name, :password

  validates :name, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { maximum: 255 }, confirmation: true, on: :with_password_change
  validates :password_confirmation, presence: true, on: :with_password_change

  def initialize(user)
    @user = user
    @name = user.name
  end

  def save
    return false unless valid?

    @user.name = @name
    if @password.present?
      @user.password_digest = DigestGenerator.digest(@password)
    end
    @user.save!

    return true
  end

  def apply(params)
    @name = params[:name]
    @password = params[:password]
    @password_confirmation = params[:password_confirmation]
  end

  def persisted?
    true
  end

  def valid?
    if @password.present?
      validate(:with_password_change)
    else
      validate
    end
  end
end
