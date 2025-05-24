<h1 dir="rtl">الجامع</h1>

<h2 dir="rtl">تجهيز بيئة التطوير</h2>

<ul dir="rtl">
  <li>ثبّت <code>Docker</code> حسب نظام تشغيلك من خلال <a href="https://docs.docker.com/engine/install/">هذا</a> الرابط.</li>
  <li>ثبّت <code>Mise</code> حسب نظام تشغيلك من خلال <a href="https://mise.jdx.dev/installing-mise.html">هذا</a> الرابط.</li>
  <li>ثبّت مكتبة <code>libpq</code> حسب نظام تشغيلك. على سبيل المثال، نفّذ هذا الأمر إذا كنت على نظام MacOS:</li>

  <pre dir="ltr">brew install libpq</pre>

  <li>أضِف مكتبة <code>libpq</code> إلى متغير <code>PATH</code> حسب نظام تشغيلك باتباع التعليمات الموضّحة بعد تثبيت المكتبة. على سبيل المثال، نفّذ هذا الأمر إذا كنت على نظام MacOS وتستخدم <code>Zsh</code>:</li>

  <pre dir="ltr">echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> /Users/{user}/.zshrc</pre>

  <li>نفّذ الأمر التالي لسحب مستودع المشروع على حاسبك:</li>

  <pre dir="ltr">git clone git@github.com:ieasybooks/aljam3.git</pre>

  <li>افتح سطر الأوامر داخل مجلد المشروع ونفّذ الأمر التالي لتثبيت أدوات <code>Mise</code> المطلوبة للتطوير:</li>

  <pre dir="ltr">mise install</pre>

  <li>نفّذ الأمر التالي لتثبيت اعتماديات المشروع وتشغيل خادم التطوير المحلّي:</li>

  <pre dir="ltr">mise dev</pre>

  <li>افتح الرابط <a href="http://localhost:3000"><code>http://localhost:3000</code></a> على متصفحك لتحصل على الصفحة الرئيسية للمشروع.</li>
</ul>

<p dir="rtl">ستحصل على الأدوات التالية باتباعك للخطوات المذكورة في الأعلى:</p>

<ul>
  <li><a href="https://docker.com">Docker</a></li>
  <li><a href="https://mise.jdx.dev">Mise</a></li>
  <li><a href="https://postgresql.org/docs/current/libpq.html">libpq</a></li>
  <li><a href="https://postgresql.org">PostgreSQL</a> (17.5)</li>
  <li><a href="https://memcached.org">Memcached</a> (1.6.38)</li>
  <li><a href="https://meilisearch.com">Meilisearch</a> (1.14.0)</li>
  <li><a href="https://ruby-lang.org">Ruby</a> (3.4.4)</li>
  <li><a href="https://rubyonrails.org">Rails</a> 8.0.2</li>
</ul>

<p dir="rtl">كما يمكنك الوصول إلى PostgreSQL و Memcached و Meilisearch من خلال المنافذ التالية:</p>

<ul>
  <li>PostgreSQL → 5433 (localhost:5433)</li>
  <li>Memcached → 11212 (localhost:11212)</li>
  <li>Meilisearch → 7701 (localhost:7701)</li>
</ul>

<p dir="rtl">
وبمجرّد إيقاف تشغيل خادم التطوير المحلّي من خلال الضغط على <code>Cmd+C</code> أو <code>Ctrl+C</code> ستتوقف خدمات <code>Docker</code> (PostgreSQL و Memcached و Meilisearch) عن العمل تلقائيا.
</p>

<h2 dir="rtl">تجهيز المحرر</h2>

<p dir="rtl">
جُهّز هذا المشروع ليعمل مع محرر VSCode أو ما يشبهه من المحررات مثل Cursor و Windsurf وغيرهما. بمجرّد فتح المشروع على أحد هذه المحررات سيظهر لك إشعار شبيه بالإشعار الموضّح في الصورة يسألك "هل تريد تثبيت الإضافات المُوصى بها؟"، إذا ضغطت على زر Install ستبدأ عملية تثبيت الإضافات الموجودة في ملف <a href=".vscode/extensions.json"><code dir="ltr">.vscode/extensions.json</code></a>.
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
  <li><a href="https://marketplace.visualstudio.com/items?itemName=marcoroth.stimulus-lsp">Stimulus LSP</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server">Live Preview</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools">SQLTools</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-pg">SQLTools PostgreSQL/Cockroach Driver</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=vscode-icons-team.vscode-icons">vscode-icons</a></li>
  <li><a href="https://marketplace.visualstudio.com/items?itemName=waderyan.gitblame">Git Blame</a></li>
</ul>

<p dir="rtl">كما أن إعدادات جميع هذه الإضافات موجودة مسبقًا في ملف <a href=".vscode/settings.json"><code dir="ltr">.vscode/settings.json</code></a>، فلا داعي لإعدادها يدويًّا.</p>
