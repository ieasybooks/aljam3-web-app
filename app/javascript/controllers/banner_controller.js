import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="banner"
export default class extends Controller {
  static RANDOM_MESSAGES = [
    {
      text: "📢 الإسلام في ٢٠٠ سؤال وجواب - عقيدة سليمة بسلاسة",
      link: "https://islam200qa.ieasybooks.com",
    },
    {
      text: "📢 باحث - الذكاء الاصطناعي في خدمة علوم الشريعة",
      link: "https://baheth.ieasybooks.com",
    },
    {
      text: "📢 تُراث - الشاملة بواجهة مبتكرة حديثة",
      link: "https://app.turath.io",
    },
    {
      text: "📢 الشاملة - ابحث في 8 آلاف كتاب إسلامي",
      link: "https://shamela.ws",
    },
    {
      text: "📢 الباحث القرآني - كل ما تحتاجه عن القرآن",
      link: "https://tafsir.app",
    },
    {
      text: "📢 التفسير التفاعلي - اقرأ واستمع للتفاسير",
      link: "https://read.tafsir.one",
    },
    {
      text: "📢 الباحث الحديثي - بحث فوري في موسوعة الدرر السنية",
      link: "https://sunnah.one",
    },
    { text: "📢 فائدة - فوائد وقراءات يومية", link: "https://faidah.app" },
    { text: "📢 راوي - استمع لآلاف الكتب الصوتية", link: "https://rawy.net" },
    {
      text: "📢 المنصة الحديثية - كل ما تحتاجه عن الحديث النبوي",
      link: "https://alminasa.ai",
    },
  ];

  static targets = ["link"];

  connect() {
    const randomMessage =
      this.constructor.RANDOM_MESSAGES[
        Math.floor(Math.random() * this.constructor.RANDOM_MESSAGES.length)
      ];

    this.linkTarget.href = randomMessage.link;
    this.linkTarget.textContent = randomMessage.text;
  }
}
