module ProsHelper
  def current_pro?(pro)
    pro.id == current_pro.id
  end

  def me_tag(pro)
    content_tag(:span, 'Vous', class: 'badge badge-info') if current_pro?(pro)
  end

  def admin_tag(pro)
    content_tag(:span, 'Admin', class: 'badge badge-danger') if pro.admin?
  end

  def invite_button(btn_style = 'btn-primary mb-5')
    link_to 'Inviter un utilisateur', new_pro_invitation_path, class: "btn #{btn_style}", data: { rightbar: true } if policy(current_pro).invite?
  end
end