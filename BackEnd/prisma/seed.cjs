// prisma/seed.js
const { PrismaClient } = require("@prisma/client");
const crypto = require("crypto");

const prisma = new PrismaClient();

function randInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function pick(arr) {
  return arr[randInt(0, arr.length - 1)];
}

function randomToken(len = 24) {
  return crypto.randomBytes(len).toString("hex");
}

// random Date between start..end (inclusive-ish)
function randomDate(start, end) {
  const s = start.getTime();
  const e = end.getTime();
  return new Date(randInt(s, e));
}

// helper: YYYY-MM-DD as Date (still JS Date object)
function dateOnly(y, m, d) {
  // m is 1-12
  return new Date(Date.UTC(y, m - 1, d));
}

async function main() {
  // =========================
  // 0) RESET (hapus data lama)
  // =========================
  // urutan penting karena FK
  await prisma.transaction.deleteMany();
  await prisma.budget.deleteMany();
  await prisma.reminder.deleteMany();
  await prisma.asset.deleteMany();
  await prisma.category.deleteMany();
  await prisma.user.deleteMany();

  // =========================
  // 1) CATEGORY (master)
  // =========================
  const categorySeed = [
    // income
    { name: "Gaji", type: "income", description: "Pendapatan gaji bulanan" },
    { name: "Bonus", type: "income", description: "Bonus / THR / insentif" },
    { name: "Freelance", type: "income", description: "Proyek freelance" },
    { name: "Investasi", type: "income", description: "Dividen / bunga / capital gain" },

    // expense
    { name: "Makan & Minum", type: "expense", description: "Konsumsi harian" },
    { name: "Transportasi", type: "expense", description: "Bensin, parkir, tiket" },
    { name: "Belanja", type: "expense", description: "Kebutuhan rumah & pribadi" },
    { name: "Tagihan", type: "expense", description: "Listrik, air, internet, cicilan" },
    { name: "Hiburan", type: "expense", description: "Streaming, nongkrong, liburan" },
    { name: "Kesehatan", type: "expense", description: "Obat, dokter, asuransi" },
    { name: "Pendidikan", type: "expense", description: "Kursus, buku, sertifikasi" },
  ];

  await prisma.category.createMany({ data: categorySeed });
  const categories = await prisma.category.findMany();

  const incomeCategories = categories.filter((c) => c.type === "income");
  const expenseCategories = categories.filter((c) => c.type === "expense");

  // =========================
  // 2) USER
  // =========================
  const people = [
    { name: "Andi Saputra", email: "andi@mail.com" },
    { name: "Budi Santoso", email: "budi@mail.com" },
    { name: "Citra Lestari", email: "citra@mail.com" },
    { name: "Dewi Kartika", email: "dewi@mail.com" },
    { name: "Eka Prasetyo", email: "eka@mail.com" },
    { name: "Fajar Hidayat", email: "fajar@mail.com" },
    { name: "Gita Aulia", email: "gita@mail.com" },
    { name: "Hana Putri", email: "hana@mail.com" },
  ];

  // password seed (kalau di app kamu ada hashing, nanti tinggal sesuaikan)
  await prisma.user.createMany({
    data: people.map((p) => ({
      email: p.email,
      name: p.name,
      password: "password123", // NOTE: biasanya di real app harus di-hash
      image_url: `https://api.dicebear.com/7.x/identicon/svg?seed=${encodeURIComponent(p.name)}`,
      token: Math.random() > 0.3 ? randomToken(16) : null,
    })),
  });

  const users = await prisma.user.findMany();

  // =========================
  // 3) ASSET (per user)
  // =========================
  const assetTypes = ["cash", "bank", "ewallet", "investasi"];

  const assetsToCreate = [];
  for (const u of users) {
    const assetCount = randInt(2, 4);
    for (let i = 0; i < assetCount; i++) {
      const first = randInt(200_000, 15_000_000);
      const current = Math.max(0, first + randInt(-500_000, 5_000_000));
      assetsToCreate.push({
        email_user: u.email,
        asset_name: `${pick(["Dompet", "BCA", "BRI", "Jago", "OVO", "DANA", "GoPay", "ReksaDana"])} ${i + 1}`,
        asset_type: pick(assetTypes),
        first_amount: first,
        current_amount: current,
      });
    }
  }

  await prisma.asset.createMany({ data: assetsToCreate });
  const assets = await prisma.asset.findMany();

  // group assets by user
  const assetsByUser = new Map();
  for (const a of assets) {
    if (!assetsByUser.has(a.email_user)) assetsByUser.set(a.email_user, []);
    assetsByUser.get(a.email_user).push(a);
  }

  // =========================
  // 4) BUDGET (per user)
  // =========================
  // periode 2025
  const periodStart = dateOnly(2025, 1, 1);
  const periodEnd = dateOnly(2025, 12, 31);

  const budgetsToCreate = [];
  for (const u of users) {
    const budgetCount = randInt(6, 12);

    for (let i = 0; i < budgetCount; i++) {
      const isExpenseBudget = Math.random() > 0.25; // mayoritas budget expense
      const cat = isExpenseBudget ? pick(expenseCategories) : pick(incomeCategories);

      const firstP = randomDate(periodStart, periodEnd);
      const lastP = randomDate(firstP, periodEnd);

      const userAssets = assetsByUser.get(u.email) || [];
      const maybeAsset = Math.random() > 0.35 && userAssets.length ? pick(userAssets) : null;

      budgetsToCreate.push({
        email_user: u.email,
        id_category: cat.id,
        amount: isExpenseBudget ? randInt(200_000, 5_000_000) : randInt(1_000_000, 25_000_000),
        first_period: firstP,
        last_period: lastP,
        id_asset: maybeAsset ? maybeAsset.id : null,
        note: Math.random() > 0.6 ? pick(["Rencana bulanan", "Target hemat", "Prioritas", "Estimasi"]) : null,
      });
    }
  }

  // createMany OK
  await prisma.budget.createMany({ data: budgetsToCreate });

  // =========================
  // 5) REMINDER (per user)
  // =========================
  const reminderPeriods = ["daily", "weekly", "monthly"];

  const remindersToCreate = [];
  for (const u of users) {
    const reminderCount = randInt(2, 6);
    for (let i = 0; i < reminderCount; i++) {
      const date = randomDate(periodStart, periodEnd);
      const amount = randInt(50_000, 3_000_000);
      remindersToCreate.push({
        email_user: u.email,
        description: pick([
          "Bayar tagihan internet",
          "Bayar listrik",
          "Bayar air",
          "Top up e-wallet",
          "Cicilan",
          "Iuran",
          "Nabung rutin",
        ]),
        period: pick(reminderPeriods),
        date,
        amount,
      });
    }
  }

  await prisma.reminder.createMany({ data: remindersToCreate });

  // =========================
  // 6) TRANSACTION (banyak data)
  // =========================
  const transactionsToCreate = [];
  for (const u of users) {
    const trxCount = randInt(60, 140); // per user
    const userAssets = assetsByUser.get(u.email) || [];

    for (let i = 0; i < trxCount; i++) {
      // campuran income & expense
      const isExpense = Math.random() > 0.2;
      const cat = isExpense ? pick(expenseCategories) : pick(incomeCategories);

      const date = randomDate(periodStart, periodEnd);
      const asset = Math.random() > 0.1 && userAssets.length ? pick(userAssets) : null;

      const amount = isExpense ? randInt(10_000, 2_500_000) : randInt(250_000, 20_000_000);

      transactionsToCreate.push({
        email_user: u.email,
        id_category: cat.id,
        id_asset: asset ? asset.id : null,
        amount,
        type: cat.type, // biar konsisten dgn Category.type
        description: Math.random() > 0.35
          ? pick([
              "Transaksi harian",
              "Pembayaran",
              "Pembelian",
              "Pemasukan",
              "Transfer",
              "Kebutuhan mendadak",
              "Langganan",
            ])
          : null,
        date,
      });
    }
  }

  // createMany transaksi (bisa besar)
  // kalau DB kamu kecil, aman. kalau terlalu besar, turunin trxCount
  await prisma.transaction.createMany({ data: transactionsToCreate });

  // =========================
  // DONE
  // =========================
  const counts = await Promise.all([
    prisma.user.count(),
    prisma.category.count(),
    prisma.asset.count(),
    prisma.budget.count(),
    prisma.reminder.count(),
    prisma.transaction.count(),
  ]);

  console.log("✅ Seed selesai. Total data:");
  console.log({
    users: counts[0],
    categories: counts[1],
    assets: counts[2],
    budgets: counts[3],
    reminders: counts[4],
    transactions: counts[5],
  });
}

main()
  .catch((e) => {
    console.error("❌ Seed error:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
