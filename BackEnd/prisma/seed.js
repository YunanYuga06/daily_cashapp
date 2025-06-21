import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log(`Mulai proses seeding...`);

    // --- Data untuk Kategori ---
    const categories = [
        { name: 'Makanan & Minuman', type: 'expense' },
        { name: 'Transportasi', type: 'expense' },
        { name: 'Tagihan', type: 'expense' },
        { name: 'Belanja', type: 'expense' },
        { name: 'Hiburan', type: 'expense' },
        { name: 'Kesehatan', type: 'expense' },
        { name: 'Pendidikan', type: 'expense' },
        { name: 'Gaji', type: 'income' },
        { name: 'Bonus', type: 'income' },
        { name: 'Investasi', type: 'income' },
    ];

    await prisma.category.createMany({
        data: categories,
        skipDuplicates: true, // Lewati jika nama kategori sudah ada
    });
    console.log(`Seeding untuk Kategori selesai.`);

    // --- Data untuk Aset ---
    // PENTING: Ganti 'test@gmail.com' dengan email user yang sudah terdaftar di database Anda.
    const userEmail = 'cobaapi@gmail.com'; 
    const user = await prisma.user.findUnique({
        where: { email: userEmail },
    });

    if (user) {
        const assets = [
            { asset_name: 'Dompet Tunai', asset_type: 'Uang Tunai', first_amount: 500000, current_amount: 500000, email_user: userEmail },
            { asset_name: 'Rekening BCA', asset_type: 'Bank', first_amount: 5000000, current_amount: 5000000, email_user: userEmail },
            { asset_name: 'GoPay', asset_type: 'E-Wallet', first_amount: 250000, current_amount: 250000, email_user: userEmail },
            { asset_name: 'OVO', asset_type: 'E-Wallet', first_amount: 150000, current_amount: 150000, email_user: userEmail },
        ];
        await prisma.asset.deleteMany({
            where: { email_user: userEmail }
        });

        await prisma.asset.createMany({
            data: assets,
        });
        console.log(`Seeding untuk Aset selesai untuk user: ${userEmail}`);
    } else {
        console.warn(`PERINGATAN: User dengan email '${userEmail}' tidak ditemukan.`);
        console.warn(`Seeding untuk Aset dilewati. Silakan buat user tersebut terlebih dahulu atau ubah email di file seed.js.`);
    }

}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        console.log("Proses seeding selesai.");
        await prisma.$disconnect();
    });