User.new(email: "aljam3@ieasybooks.com", password: "aljam3@ieasybooks.com", role: :admin).tap(&:skip_confirmation!).save

Library.find_or_create_by(name: "المكتبة الشاملة الوقفية")
Library.find_or_create_by(name: "المكتبة الوقفية")
Library.find_or_create_by(name: "مكتبة المسجد النبوي")
