import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    const userEmail = 'bejo@gmail.com'; 
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