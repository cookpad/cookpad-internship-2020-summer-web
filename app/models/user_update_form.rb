class UserUpdateForm
  include ActiveModel::Validations

  attr_accessor :name, :password

  validates :name, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { maximum: 255 }, confirmation: true, on: :with_password_change
  validates :password_confirmation, presence: true, on: :with_password_change

  def initialize(model = nil)
    @name = model&.name
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

  def to_attributes
    if @password.present?
      {
        name: @name,
        password_digest: DigestGenerator.digest(@password),
      }
    else
      { name: @name }
    end
  end
end
