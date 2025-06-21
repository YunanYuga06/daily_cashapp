-- AlterTable
ALTER TABLE `budget` ADD COLUMN `id_asset` INTEGER NULL;

-- CreateTable
CREATE TABLE `assets` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `email_user` VARCHAR(255) NOT NULL,
    `asset_name` VARCHAR(255) NOT NULL,
    `asset_type` VARCHAR(255) NOT NULL,
    `first_amount` INTEGER NOT NULL,
    `current_amount` INTEGER NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `assets` ADD CONSTRAINT `assets_email_user_fkey` FOREIGN KEY (`email_user`) REFERENCES `users`(`email`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Budget` ADD CONSTRAINT `Budget_id_asset_fkey` FOREIGN KEY (`id_asset`) REFERENCES `assets`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
