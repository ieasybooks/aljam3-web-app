class Views::Static::Privacy < Views::Base
  def view_template
    div(class: "max-w-3xl mx-auto p-6 lg:p-8 space-y-8 bg-background text-foreground", dir: "rtl", lang: "ar") do
      header(class: "space-y-2") do
        h1(class: "text-3xl font-bold tracking-tight text-foreground") { "سياسة الخصوصية" }
        p(class: "text-sm text-muted-foreground") do
          plain "آخر تحديث: 14/08/2025"
        end
        p(class: "text-muted-foreground") do
          plain "في موقع "
          a(href: "https://aljam3.com", class: "underline decoration-dotted hover:decoration-solid text-primary") { "aljam3.com" }
          plain " (منصة لاستضافة الكتب بصيغ PDF وText وWord مع إمكانات البحث والتنزيل) نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية وفقًا للقوانين المعمول بها."
        end
      end

      nav(class: "bg-card border border-border rounded-xl p-4") do
        ul(class: "grid sm:grid-cols-2 gap-2 text-sm") do
          li { a(href: "#data-collection", class: "hover:underline text-primary") { "1) المعلومات التي نجمعها" } }
          li { a(href: "#use-of-data", class: "hover:underline text-primary") { "2) كيفية استخدام المعلومات" } }
          li { a(href: "#cookies", class: "hover:underline text-primary") { "3) ملفات تعريف الارتباط" } }
          li { a(href: "#sharing", class: "hover:underline text-primary") { "4) مشاركة البيانات" } }
          li { a(href: "#security", class: "hover:underline text-primary") { "5) حماية البيانات" } }
          li { a(href: "#your-rights", class: "hover:underline text-primary") { "6) حقوقك" } }
          li { a(href: "#changes", class: "hover:underline text-primary") { "7) التغييرات على هذه السياسة" } }
          li { a(href: "#contact", class: "hover:underline text-primary") { "8) التواصل معنا" } }
        end
      end

      section(id: "data-collection", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "1) المعلومات التي نجمعها" }
        ul(class: "list-disc pr-6 space-y-2 text-muted-foreground") do
          li { "معلومات تُقدِّمها عند التواصل معنا (مثل الاسم والبريد الإلكتروني) أو عند الإبلاغ عن مشكلة محتوى/حقوق." }
          li { "بيانات تقنية تُجمَع تلقائيًا: عنوان IP، نوع وإصدار المتصفح، نظام التشغيل، تفضيلات اللغة، الجهاز، ومُعرّفات الجلسات." }
          li { "بيانات الاستخدام: عمليات البحث داخل الكتب، الصفحات والكتب التي تزورها، مرات التنزيل، وقت وتاريخ الطلبات." }
          li { "ملفات سجلات الخادم وبيانات الأمان للكشف عن إساءة الاستخدام ومنع الاحتيال." }
        end
      end

      section(id: "use-of-data", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "2) كيفية استخدام المعلومات" }
        p(class: "text-muted-foreground") { "نستخدم بياناتك للأغراض التالية:" }
        ul(class: "list-disc pr-6 space-y-2 text-muted-foreground") do
          li { "تشغيل المنصة وتمكين ميزات البحث وتنزيل الكتب وتحسين الأداء." }
          li { "فهم تفاعلك مع المحتوى وتحسين جودة الفهرسة وتجربة القراءة." }
          li { "تحليل المقاييس والاستخدام لأغراض إحصائية وأمنية." }
          li { "التواصل معك بخصوص الاستفسارات أو البلاغات أو التحديثات المهمة ذات الصلة بالخدمة." }
        end
      end

      section(id: "cookies", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "3) ملفات تعريف الارتباط (Cookies)" }
        p(class: "text-muted-foreground") do
          "نستخدم ملفات تعريف الارتباط وتقنيات مشابهة لتذكّر تفضيلاتك وتحسين الأداء وقياس الاستخدام. يمكنك إدارة أو تعطيل ملفات الارتباط من إعدادات المتصفح؛ قد يؤثر ذلك على بعض الوظائف مثل تذكّر تفضيلات البحث."
        end
      end

      section(id: "sharing", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "4) مشاركة البيانات" }
        p(class: "text-muted-foreground") do
          "لا نبيع بياناتك الشخصية. قد نشارك بياناتًا محدودة مع مزودي خدمات موثوقين (مثل الاستضافة والتحليلات) وفق اتفاقيات سرية ومعالجة بيانات، أو عندما يُطلب منا قانونيًا الامتثال لالتزامات نظامية أو أوامر قضائية."
        end
      end

      section(id: "security", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "5) حماية البيانات" }
        p(class: "text-muted-foreground") do
          "نطبق إجراءات معقولة فنيًا وتنظيميًا لحماية البيانات من الوصول أو الاستخدام غير المصرّح بهما. ومع ذلك فلا توجد وسيلة نقل إلكترونية أو تخزين يمكن ضمان أمانها بنسبة 100%."
        end
      end

      section(id: "your-rights", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "6) حقوقك" }
        ul(class: "list-disc pr-6 space-y-2 text-muted-foreground") do
          li { "الوصول إلى بياناتك الشخصية التي نحتفظ بها، عند الإمكان." }
          li { "طلب تصحيح أو تحديث بياناتك غير الدقيقة." }
          li { "طلب حذف بياناتك عندما لا تكون هناك حاجة مشروعة للاحتفاظ بها." }
          li { "الاعتراض على بعض أنشطة المعالجة أو تقييدها وفقًا للإطار القانوني المطبّق." }
        end
        p(class: "text-muted-foreground") do
          plain "لممارسة أي من هذه الحقوق، راسلنا عبر البريد الموضح أدناه وسنقوم بمراجعة الطلب وفق القوانين المعمول بها."
        end
      end

      section(id: "changes", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "7) التغييرات على هذه السياسة" }
        p(class: "text-muted-foreground") do
          "قد نقوم بتحديث هذه السياسة من وقت لآخر لتعكس تغييرات في الممارسات أو لأسباب قانونية أو تشغيلية. سننشر النسخة المحدّثة على هذه الصفحة مع تاريخ السريان."
        end
      end

      section(id: "contact", class: "space-y-3") do
        h2(class: "text-xl font-semibold text-foreground") { "8) التواصل معنا" }
        p(class: "text-muted-foreground") do
          plain "للاستفسارات أو لطلبات الخصوصية، يمكنك مراسلتنا على: "
          a(href: "mailto:easybooksdev@gmail.com", class: "font-medium underline hover:no-underline text-primary") { "easybooksdev@gmail.com" }
        end
      end
    end
  end
end
