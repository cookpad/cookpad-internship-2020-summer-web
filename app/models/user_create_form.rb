class UserCreateForm
  include ActiveModel::Validations

  attr_accessor :name, :password
  attr_reader :user

  validates :name, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { maximum: 255 }, confirmation: true
  validates :password_confirmation, presence: true

  def initialize(user)
    @user = user
  end

  def apply(params)
    @name = params[:name]
    @password = params[:password]
    @password_confirmation = params[:password_confirmation]
  end

  def save
    return false unless valid?

    @user.name = @name
    @user.password_digest = DigestGenerator.digest(@password)
    @user.save!

    return true
  end

  def persisted?
    false
  end
end
