class UserCreateForm
  include ActiveModel::Validations

  attr_accessor :name, :password

  validates :name, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { maximum: 255 }, confirmation: true
  validates :password_confirmation, presence: true

  def apply(params)
    @name = params[:name]
    @password = params[:password]
    @password_confirmation = params[:password_confirmation]
  end

  def persisted?
    false
  end

  def to_attributes
    {
      name: @name,
      password_digest: DigestGenerator.digest(@password),
    }
  end
end
