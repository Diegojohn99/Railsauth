class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if email_already_taken?(user_params[:email_address])
      @user.errors.add(:email_address, "ya existe esa cuenta, prueba con otro")
      render :new, status: :unprocessable_entity
      return
    end

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Bienvenido. Tu cuenta fue creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def email_already_taken?(email)
      normalized_email = email.to_s.strip.downcase
      return false if normalized_email.blank?

      User.where("LOWER(email_address) = ?", normalized_email).exists?
    end

    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
