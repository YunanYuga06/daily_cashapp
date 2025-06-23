import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log(`Mulai proses seeding...`);


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
        skipDuplicates: true,
    });
    console.log(`Seeding untuk Kategori selesai.`);

    const userEmail = 'cobaapi@gmail.com'; 
    const user = await prisma.user.findUnique({
        where: { email: userEmail },
    });

    if (user) {
        const assetsData = [
            { asset_name: 'Dompet Tunai', asset_type: 'Uang Tunai', first_amount: 500000, current_amount: 500000, email_user: userEmail },
            { asset_name: 'Rekening BCA', asset_type: 'Bank', first_amount: 5000000, current_amount: 5000000, email_user: userEmail },
            { asset_name: 'GoPay', asset_type: 'E-Wallet', first_amount: 250000, current_amount: 250000, email_user: userEmail },
        ];
        await prisma.asset.deleteMany({ where: { email_user: userEmail }});
        await prisma.asset.createMany({ data: assetsData });
        console.log(`Seeding untuk Aset selesai untuk user: ${userEmail}`);
        console.log('Mempersiapkan data untuk Transaksi...');
        const allCategories = await prisma.category.findMany();
        const allAssets = await prisma.asset.findMany({ where: { email_user: userEmail }});
        const categoryMap = new Map(allCategories.map(c => [c.name, c.id]));
        const assetMap = new Map(allAssets.map(a => [a.asset_name, a.id]));
        const today = new Date();
        const transactionsData = [
            {
                id_category: categoryMap.get('Gaji'),
                id_asset: assetMap.get('Rekening BCA'),
                amount: 5000000,
                type: 'income',
                description: 'Gaji bulanan',
                date: new Date(today.getFullYear(), today.getMonth(), 1),
            },
            {
                id_category: categoryMap.get('Bonus'),
                id_asset: assetMap.get('Rekening BCA'),
                amount: 750000,
                type: 'income',
                description: 'Bonus project',
                date: new Date(today.getFullYear(), today.getMonth(), 5),
            },
            {
                id_category: categoryMap.get('Makanan & Minuman'),
                id_asset: assetMap.get('GoPay'),
                amount: 55000,
                type: 'expense',
                description: 'Makan siang di warteg',
                date: new Date(today.getFullYear(), today.getMonth(), 3),
            },
            {
                id_category: categoryMap.get('Transportasi'),
                id_asset: assetMap.get('Dompet Tunai'),
                amount: 20000,
                type: 'expense',
                description: 'Naik ojek online',
                date: new Date(today.getFullYear(), today.getMonth(), 4),
            },
            {
                id_category: categoryMap.get('Tagihan'),
                id_asset: assetMap.get('Rekening BCA'),
                amount: 250000,
                type: 'expense',
                description: 'Bayar tagihan internet',
                date: new Date(today.getFullYear(), today.getMonth(), 6),
            },
            {
                id_category: categoryMap.get('Belanja'),
                id_asset: assetMap.get('Rekening BCA'),
                amount: 150000,
                type: 'expense',
                description: 'Belanja bulanan',
                date: new Date(today.getFullYear(), today.getMonth(), 7),
            },
             {
                id_category: categoryMap.get('Hiburan'),
                amount: 120000,
                type: 'expense',
                description: 'Nonton bioskop',
                date: new Date(today.getFullYear(), today.getMonth(), 8),
            }
        ].map(t => ({ ...t, email_user: userEmail }));
        await prisma.transaction.deleteMany({ where: { email_user: userEmail }});
        await prisma.transaction.createMany({
            data: transactionsData,
        });
        console.log(`Seeding untuk Transaksi selesai untuk user: ${userEmail}`);

    } else {
        console.warn(`PERINGATAN: User dengan email '${userEmail}' tidak ditemukan.`);
        console.warn(`Seeding untuk Aset dan Transaksi dilewati. Silakan buat user tersebut terlebih dahulu atau ubah email di file seed.js.`);
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