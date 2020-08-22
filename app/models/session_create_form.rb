class SessionCreateForm
  include ActiveModel::Validations

  attr_accessor :name, :password

  validates :name, presence: true
  validates :password, presence: true
  validate :identify

  def apply(params)
    @name = params[:name]
    @password = params[:password]
  end

  def persisted?
    false
  end

  def identified_user
    @identified_user
  end

  private def identify
    # Do not add errors to avoid verbose error
    return if errors.present?

    user = User.find_by(name: @name)
    if user && DigestGenerator.validate(@password, user.password_digest)
      @identified_user = user
    else
      errors.add(:name, 'or password is wrong.')
    end
  end
end
