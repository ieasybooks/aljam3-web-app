<p align="center">
  <img width="250px" src="public/icon-v2.png"/>
</p>

<h1 dir="rtl">الجامع</h1>

<p dir="rtl">مكتبة المكتبات الإسلامية</p>

<div dir="rtl">
  <img src="https://img.shields.io/badge/Ruby-3.4.4-red?style=for-the-badge&logo=ruby" alt="Ruby Version">
  <img src="https://img.shields.io/badge/Rails-8.0.2-red?style=for-the-badge&logo=rubyonrails" alt="Rails Version">
  <img src="https://img.shields.io/badge/Node.js-24.1.0-green?style=for-the-badge&logo=node.js" alt="Node.js Version">
  <img src="https://img.shields.io/badge/Yarn-4.9.1-blue?style=for-the-badge&logo=yarn" alt="Yarn Version">
  <img src="https://img.shields.io/badge/PostgreSQL-17.5-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL Version">
  <img src="https://img.shields.io/badge/Meilisearch-1.15.1-deeppink?style=for-the-badge&logo=meilisearch" alt="Meilisearch Version">
</div>

<br>

<div align="center">

  [![ar](https://img.shields.io/badge/lang-ar-brightgreen.svg)](README.md)
  [![en](https://img.shields.io/badge/lang-en-red.svg)](README.en.md)

</div>

<h2 dir="rtl">🚀 تجهيز بيئة التطوير</h2>

<h3 dir="rtl">المتطلبات الأساسية</h3>

<ol dir="rtl">
  <li>ثبّت Docker حسب نظام تشغيلك من خلال <a href="https://docs.docker.com/engine/install">هذا الرابط</a></li>
  <li>ثبّت Mise حسب نظام تشغيلك من خلال <a href="https://mise.jdx.dev/installing-mise.html">هذا الرابط</a></li>
  <li>ثبّت مكتبة <code>gpg</code> حسب نظام تشغيلك. على سبيل المثال، نفّذ هذا الأمر إذا كنت تستخدم نظام macOS:</li>
  <pre dir="ltr">brew install gnupg</pre>
  <li>ثبّت مكتبة <code>libpq</code> حسب نظام تشغيلك. على سبيل المثال، نفّذ هذا الأمر إذا كنت تستخدم نظام macOS:</li>
  <pre dir="ltr">brew install libpq</pre>
  <li>أضِف مكتبة <code>libpq</code> إلى متغير <code>PATH</code> حسب نظام تشغيلك باتباع التعليمات الموضّحة بعد تثبيت المكتبة. على سبيل المثال، نفّذ هذا الأمر إذا كنت تستخدم نظام macOS مع <code>Zsh</code>:</li>
  <pre dir="ltr">echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> /Users/{user}/.zshrc</pre>
</ol>

<h3 dir="rtl">إعداد المشروع</h3>

<ol dir="rtl">
  <li>نفّذ الأمر التالي لنسخ مستودع المشروع إلى حاسبك:</li>
  <pre dir="ltr">git clone git@github.com:ieasybooks/aljam3-web-app.git</pre>
  <li>افتح سطر الأوامر داخل مجلد المشروع ونفّذ الأمر التالي لتثبيت الأدوات المطلوبة للتطوير من خلال <code>Mise</code>:</li>
  <pre dir="ltr">mise install</pre>
  <li>نفّذ الأمر التالي لتثبيت اعتماديات المشروع وتشغيل خادم التطوير المحلّي:</li>
  <pre dir="ltr">mise dev</pre>
  <li>افتح الرابط <a href="http://localhost:3000"><code>http://localhost:3000</code></a> في متصفحك للوصول إلى الصفحة الرئيسية للمشروع</li>
</ol>

<h3 dir="rtl">الأدوات المُثبتة</h3>

<p dir="rtl">ستحصل على الأدوات التالية باتباعك للخطوات المذكورة أعلاه:</p>

<ul>
  <li><a href="https://docker.com">Docker</a></li>
  <li><a href="https://mise.jdx.dev">Mise</a></li>
  <li><a href="https://www.gnupg.org">gnupg</a></li>
  <li><a href="https://postgresql.org/docs/current/libpq.html">libpq</a></li>
  <li><a href="https://ruby-lang.org">Ruby</a> (3.4.4)</li>
  <li><a href="https://rubyonrails.org">Rails</a> (8.0.2)</li>
  <li><a href="https://nodejs.org">Node.js</a> (24.1.0)</li>
  <li><a href="https://yarnpkg.com">Yarn</a> (4.9.1)</li>
  <li><a href="https://postgresql.org">PostgreSQL</a> (17.5)</li>
  <li><a href="https://meilisearch.com">Meilisearch</a> (1.15.1)</li>
</ul>

<h3 dir="rtl">المنافذ والخدمات</h3>

<p dir="rtl">يمكنك الوصول إلى الخدمات من خلال المنافذ التالية:</p>

<ul>
  <li>PostgreSQL → 5433 (localhost:5433)</li>
  <li>Meilisearch → 7701 (localhost:7701)</li>
</ul>

<p dir="rtl">وبمجرّد إيقاف تشغيل خادم التطوير المحلّي من خلال الضغط على <code>Cmd+C</code> أو <code>Ctrl+C</code>، ستتوقف خدمات <code>Docker</code> (PostgreSQL و Meilisearch) عن العمل تلقائيًا.</p>

<h2 dir="rtl">⚙️ تجهيز المحرر</h2>

<p dir="rtl">
أُعِدّ هذا المشروع ليعمل مع محرر VSCode أو ما يشبهه من المحررات مثل Cursor و Windsurf وغيرهما. بمجرّد فتح المشروع في أحد هذه المحررات سيظهر لك إشعار يسألك "هل تريد تثبيت الإضافات المُوصى بها؟"، وإذا ضغطت على زر Install ستبدأ عملية تثبيت الإضافات الموجودة في ملف <a href=".vscode/extensions.json"><code dir="ltr">.vscode/extensions.json</code></a>.
</p>

<p align="center">
  <img src="docs/recommended-extensions.png" width="350px" />
</p>

<p dir="rtl">الإضافات المُوصى بها:</p>

<ul>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=Shopify.ruby-lsp">Ruby LSP</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=aki77.rails-db-schema">Rails DB Schema</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=aki77.rails-i18n">Rails I18n</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss">Tailwind CSS IntelliSense</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=bung87.vscode-gemfile">vscode-gemfile</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens">GitLens — Git supercharged</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=hverlin.mise-vscode">Mise VSCode</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=marcoroth.stimulus-lsp">Stimulus LSP</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server">Live Preview</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools">SQLTools</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-pg">SQLTools PostgreSQL/Cockroach Driver</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=vscode-icons-team.vscode-icons">vscode-icons</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=waderyan.gitblame">Git Blame</a></li>
</ul>

<p dir="rtl">كما أن إعدادات جميع هذه الإضافات موجودة مسبقًا في ملف <a href=".vscode/settings.json"><code dir="ltr">.vscode/settings.json</code></a>، لذا لا داعي لإعدادها يدويًّا.</p>

<h2 dir="rtl">💎 المكتبات المستخدمة للغة Ruby</h2>

<p dir="rtl"><em>ملاحظة: جميع المكتبات يجب أن تكون مُحددة بإصدار مُعيّن لضمان الاستقرار والتوافق.</em></p>

<h3 dir="rtl">المصادقة والأمان</h3>
<ul dir="ltr">
  <li><a href="https://github.com/heartcombo/devise">devise</a></li>
  <li><a href="https://github.com/tigrish/devise-i18n">devise-i18n</a></li>
  <li><a href="https://github.com/omniauth/omniauth">omniauth</a></li>
  <li><a href="https://github.com/zquestz/omniauth-google-oauth2">omniauth-google-oauth2</a></li>
  <li><a href="https://github.com/cookpad/omniauth-rails_csrf_protection">omniauth-rails_csrf_protection</a></li>
  <li><a href="https://github.com/rack/rack-attack">rack-attack</a></li>
  <li><a href="https://github.com/instrumentl/rails-cloudflare-turnstile">rails_cloudflare_turnstile</a></li>
</ul>

<h3 dir="rtl">البحث والأداء والتحسين</h3>
<ul dir="ltr">
  <li><a href="https://github.com/salsify/goldiloader">goldiloader</a></li>
  <li><a href="https://github.com/meilisearch/meilisearch-rails">meilisearch-rails</a></li>
  <li><a href="https://github.com/ohler55/oj">oj</a></li>
  <li><a href="https://github.com/ddnexus/pagy">pagy</a></li>
  <li><a href="https://github.com/kjvarga/sitemap_generator">sitemap_generator</a></li>
</ul>

<h3 dir="rtl">واجهة المستخدم</h3>
<ul dir="ltr">
  <li><a href="https://github.com/lookbook-hq/lookbook">lookbook</a></li>
  <li><a href="https://github.com/AliOsm/phlex-icons">phlex-icons</a></li>
  <li><a href="https://github.com/yippee-fun/phlex-rails">phlex-rails</a></li>
  <li><a href="https://github.com/svenfuchs/rails-i18n">rails-i18n</a></li>
  <li><a href="https://github.com/ruby-ui/ruby_ui">ruby_ui</a></li>
  <li><a href="https://github.com/gjtorikian/tailwind_merge">tailwind_merge</a></li>
</ul>

<h3 dir="rtl">التطوير والاختبار</h3>
<ul dir="ltr">
  <li><a href="https://github.com/gregnavis/active_record_doctor">active_record_doctor</a></li>
  <li><a href="https://github.com/sporkmonger/addressable">addressable</a></li>
  <li><a href="https://github.com/drwl/annotaterb">annotaterb</a></li>
  <li><a href="https://github.com/BetterErrors/better_errors">better_errors</a></li>
  <li><a href="https://github.com/banister/binding_of_caller">binding_of_caller</a></li>
  <li><a href="https://github.com/igorkasyanchuk/cache_with_locale">cache_with_locale</a></li>
  <li><a href="https://github.com/thoughtbot/factory_bot_rails">factory_bot_rails</a></li>
  <li><a href="https://github.com/faker-ruby/faker">faker</a></li>
  <li><a href="https://github.com/hotwired/spark">hotwire-spark</a></li>
  <li><a href="https://github.com/glebm/i18n-tasks">i18n-tasks</a></li>
  <li><a href="https://github.com/net-ssh/net-ssh">net-ssh</a></li>
  <li><a href="https://github.com/rspec/rspec-rails">rspec-rails</a></li>
  <li><a href="https://github.com/rubocop/rubocop-rake">rubocop-rake</a></li>
  <li><a href="https://github.com/rubocop/rubocop-rspec">rubocop-rspec</a></li>
  <li><a href="https://github.com/rubocop/rubocop-rspec_rails">rubocop-rspec_rails</a></li>
  <li><a href="https://github.com/thoughtbot/shoulda-matchers">shoulda-matchers</a></li>
  <li><a href="https://github.com/vicentllongo/simplecov-json">simplecov-json</a></li>
  <li><a href="https://github.com/simplecov-ruby/simplecov">simplecov</a></li>
  <li><a href="https://github.com/powerpak/tqdm-ruby">tqdm</a></li>
  <li><a href="https://github.com/bblimke/webmock">webmock</a></li>
</ul>

<h3 dir="rtl">الإنتاج والمراقبة</h3>
<ul dir="ltr">
  <li><a href="https://github.com/avo-hq/avo">avo</a></li>
  <li><a href="https://github.com/fnando/browser">browser</a></li>
  <li><a href="https://github.com/modosc/cloudflare-rails">cloudflare-rails</a></li>
  <li><a href="https://github.com/schneems/get_process_mem">get_process_mem</a></li>
  <li><a href="https://github.com/SamSaffron/memory_profiler">memory_profiler</a></li>
  <li><a href="https://github.com/rails/mission_control-jobs">mission_control-jobs</a></li>
  <li><a href="https://github.com/pganalyze/pg_query">pg_query</a></li>
  <li><a href="https://github.com/ankane/pghero">pghero</a></li>
  <li><a href="https://github.com/MiniProfiler/rack-mini-profiler">rack-mini-profiler</a></li>
  <li><a href="https://github.com/igorkasyanchuk/rails_performance">rails_performance</a></li>
  <li><a href="https://github.com/fractaledmind/solid_errors">solid_errors</a></li>
  <li><a href="https://github.com/tmm1/stackprof">stackprof</a></li>
  <li><a href="https://github.com/yippee-fun/strict_ivars">strict_ivars</a></li>
  <li><a href="https://github.com/djberg96/sys-cpu">sys-cpu</a></li>
  <li><a href="https://github.com/djberg96/sys-filesystem">sys-filesystem</a></li>
</ul>

<p dir="rtl">بالإضافة إلى مكتبات إطار عمل Ruby on Rails الأساسية.</p>

<h2 dir="rtl">🟨 المكتبات المستخدمة للغة JavaScript</h2>

<p dir="rtl"><em>ملاحظة: جميع المكتبات يجب أن تكون مُحددة بإصدار مُعيّن لضمان الاستقرار والتوافق.</em></p>

<ul dir="ltr">
  <li><a href="https://github.com/floating-ui/floating-ui" dir="ltr">@floating-ui/dom</a></li>
  <li><a href="https://github.com/rails/request.js" dir="ltr">@rails/request.js</a></li>
  <li><a href="https://github.com/stimulus-components/stimulus-components" dir="ltr">@stimulus-components/clipboard</a></li>
  <li><a href="https://github.com/stimulus-components/stimulus-components" dir="ltr">@stimulus-components/read-more</a></li>
  <li><a href="https://github.com/tailwindlabs/tailwindcss-forms" dir="ltr">@tailwindcss/forms</a></li>
  <li><a href="https://github.com/tailwindlabs/tailwindcss-typography" dir="ltr">@tailwindcss/typography</a></li>
  <li><a href="https://github.com/davidjerleke/embla-carousel">embla-carousel</a></li>
  <li><a href="https://github.com/prettier/prettier">prettier</a></li>
  <li><a href="https://github.com/orchidjs/tom-select">tom-select</a></li>
  <li><a href="https://github.com/Wombosvideo/tw-animate-css">tw-animate-css</a></li>
</ul>

<p dir="rtl">بالإضافة إلى مكتبات إطار عمل Ruby on Rails الأساسية.</p>

<h2 dir="rtl">🧪 تشغيل حالات الاختبار</h2>

<p dir="rtl"><em>ملاحظة: نسعى في هذا المشروع إلى المحافظة على تغطية كاملة (100%) للشيفرة المصدرية بحالات اختبار دقيقة ومفيدة.</em></p>

<ol dir="rtl">
  <li>شغّل خادم التطوير من خلال تنفيذ الأمر <code dir="ltr">mise dev</code> أو ابدأ تشغيل خدمات Docker الخاصة بالمشروع من خلال تنفيذ الأمر <code dir="ltr">mise docker:start</code></li>
  <li>نفّذ الأمر <code dir="ltr">CI=1 bundle exec rspec</code> لتشغيل حالات الاختبار</li>
  <li>ستحصل على تقرير بنسبة تغطية الشيفرة المصدرية بحالات الاختبار ويمكنك تصفّح التقرير المُفصّل الموجود في <code dir="ltr">coverage/index.html</code></li>
  <li>أوقف تشغيل خادم التطوير أو أوقف خدمات Docker إذا كنت شغّلتها من خلال تنفيذ الأمر <code dir="ltr">mise docker:stop</code></li>
</ol>

<p align="center">
  <img src="docs/coverage-report.png" />
</p>

<h2 dir="rtl">🗃️ إضافة بيانات حقيقية إلى المشروع</h2>

<p dir="rtl">يمكنك إضافة كتب حقيقية إلى المشروع من إحدى المكتبات المُعالجة رقميًا التالية:</p>

<ul dir="rtl">
  <li><a href="https://huggingface.co/datasets/ieasybooks-org/prophet-mosque-library"><strong>مكتبة المسجد النبوي</strong></a></li>
  <li><a href="https://huggingface.co/datasets/ieasybooks-org/waqfeya-library"><strong>المكتبة الوقفية</strong></a></li>
  <li><a href="https://huggingface.co/datasets/ieasybooks-org/shamela-waqfeya-library"><strong>المكتبة الشاملة الوقفية</strong></a></li>
</ul>

<h3 dir="rtl">خطوات إضافة كتاب في بيئة التطوير</h3>

<ol dir="rtl">
  <li>اختر إحدى المكتبات واستعرض الكتب المتاحة</li>
  <li>احصل على روابط تحميل ملفات PDF و TXT و DOCX للكتاب المطلوب من مستودع المكتبة على HuggingFace</li>
  <li>نفّذ الأمر التالي مع استبدال المتغيرات بالقيم المناسبة:</li>
</ol>

<pre dir="ltr">
rake db:import_book -- \
  --title="القول الصواب في حكم النسخ في الكتاب" \
  --author="ـ" \
  --category="علوم القرآن" \
  --pages=16 \
  --volumes=-1 \
  --library-id=1 \
  --pdf-urls="https://huggingface.co/datasets/ieasybooks-org/prophet-mosque-library/resolve/main/pdf/1%D9%80%20211.0%20%D8%B9%D9%84%D9%88%D9%85%20%D8%A7%D9%84%D9%82%D8%B1%D8%A2%D9%86/00016%D9%80%20%D8%A7%D9%84%D9%82%D9%88%D9%84%20%D8%A7%D9%84%D8%B5%D9%88%D8%A7%D8%A8%20%D9%81%D9%8A%20%D8%AD%D9%83%D9%85%20%D8%A7%D9%84%D9%86%D8%B3%D8%AE%20%D9%81%D9%8A%20%D8%A7%D9%84%D9%83%D8%AA%D8%A7%D8%A8%20---%20%D9%80.PDF/KTB.pdf" \
  --txt-urls="https://huggingface.co/datasets/ieasybooks-org/prophet-mosque-library/resolve/main/txt/1%D9%80%20211.0%20%D8%B9%D9%84%D9%88%D9%85%20%D8%A7%D9%84%D9%82%D8%B1%D8%A2%D9%86/00016%D9%80%20%D8%A7%D9%84%D9%82%D9%88%D9%84%20%D8%A7%D9%84%D8%B5%D9%88%D8%A7%D8%A8%20%D9%81%D9%8A%20%D8%AD%D9%83%D9%85%20%D8%A7%D9%84%D9%86%D8%B3%D8%AE%20%D9%81%D9%8A%20%D8%A7%D9%84%D9%83%D8%AA%D8%A7%D8%A8%20---%20%D9%80.PDF/KTB.txt" \
  --docx-urls="https://huggingface.co/datasets/ieasybooks-org/prophet-mosque-library/resolve/main/docx/1%D9%80%20211.0%20%D8%B9%D9%84%D9%88%D9%85%20%D8%A7%D9%84%D9%82%D8%B1%D8%A2%D9%86/00016%D9%80%20%D8%A7%D9%84%D9%82%D9%88%D9%84%20%D8%A7%D9%84%D8%B5%D9%88%D8%A7%D8%A8%20%D9%81%D9%8A%20%D8%AD%D9%83%D9%85%20%D8%A7%D9%84%D9%86%D8%B3%D8%AE%20%D9%81%D9%8A%20%D8%A7%D9%84%D9%83%D8%AA%D8%A7%D8%A8%20---%20%D9%80.PDF/KTB.docx"
</pre>

<h3 dir="rtl">خطوات إضافة مكتبة كاملة إلى قاعدة بيانات الجامع بعد نشره</h3>

<p dir="rtl"><em>ملاحظة: هذه الخطوات مخصصة لإضافة المكتبات الكاملة إلى الجامع بعد نشره، وليس في بيئة التطوير.</em></p>

<ol dir="rtl">
  <li>
    حمّل ملف <code dir="ltr">index.tsv</code> الخاص بالمكتبة المطلوبة من مستودعها على <a href="https://huggingface.co">HuggingFace</a>. على سبيل المثال، يمكنك تحميل ملف فهرس المكتبة الوقفية من <a href="https://huggingface.co/datasets/ieasybooks-org/waqfeya-library/blob/main/index.tsv">هذا</a> الرابط.
  </li>

  <li>
    نفّذ الأمر التالي مع تعديل المتغيرات حسب المكتبة المطلوبة:
  </li>
</ol>

<pre dir="ltr">
ruby script/import_books.rb \
  --index-path=path/to/index.tsv \
  --huggingface-library-id=ieasybooks-org/library-dataset-id \
  --aljam3-library-id=0 \
  --server-ip=$SERVER_IP \
  --server-username=$SERVER_USERNAME
</pre>

<p dir="rtl">على سبيل المثال، الأمر التالي يُضيف المكتبة الوقفية إلى الجامع</p>

<pre dir="ltr">
ruby script/import_books.rb \
  --index-path=/path/to/index.tsv \
  --huggingface-library-id=ieasybooks-org/waqfeya-library \
  --aljam3-library-id=2 \
  --server-ip=$SERVER_IP \
  --server-username=$SERVER_USERNAME
</pre>
