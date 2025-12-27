const els = {
  eurusd: document.getElementById("eurusd"),
  usdeur: document.getElementById("usdeur"),
  statusText: document.getElementById("statusText"),
  statusMark: document.getElementById("statusMark"),
  updatedAt: document.getElementById("updatedAt"),
  refreshBtn: document.getElementById("refreshBtn"),
  intervalLabel: document.getElementById("intervalLabel"),
};

const REFRESH_MINUTES = 60;
els.intervalLabel.textContent = String(REFRESH_MINUTES);

function fmt(n) {
  return Number(n).toFixed(5);
}

async function fetchRate(base, symbols) {
  const url = new URL("https://api.exchangerate.host/latest");
  url.searchParams.set("base", base);
  url.searchParams.set("symbols", symbols);

  const res = await fetch(url.toString(), { cache: "no-store" });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return await res.json();
}

function setStatus(text, ok = null) {
  els.statusText.textContent = text;

  if (ok === true) {
    els.statusMark.style.display = "block";
    els.statusMark.textContent = "OK";
    els.statusMark.className = "ok";
  } else if (ok === false) {
    els.statusMark.style.display = "block";
    els.statusMark.textContent = "ERR";
    els.statusMark.className = "bad";
  } else {
    els.statusMark.style.display = "none";
  }
}

async function update() {
  setStatus("Обновляю…", null);

  try {
    // 1 EUR -> USD
    const d1 = await fetchRate("EUR", "USD");
    const eurusd = d1?.rates?.USD;

    // 1 USD -> EUR
    const d2 = await fetchRate("USD", "EUR");
    const usdeur = d2?.rates?.EUR;

    if (!eurusd || !usdeur) throw new Error("Неожиданный формат ответа API");

    els.eurusd.textContent = fmt(eurusd);
    els.usdeur.textContent = fmt(usdeur);

    const now = new Date();
    els.updatedAt.textContent = now.toLocaleString("ru-RU");
    setStatus("Курс обновлён", true);
  } catch (e) {
    setStatus(`Ошибка обновления: ${e.message}`, false);
  }
}

els.refreshBtn.addEventListener("click", update);

// первый запуск + обновление раз в час
update();
setInterval(update, REFRESH_MINUTES * 60 * 1000);
