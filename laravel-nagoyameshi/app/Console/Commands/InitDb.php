<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class InitDb extends Command
{
    protected $signature = 'init:db';
    protected $description = '初期SQLを流し込む';

    public function handle()
    {
        $sqlFile = base_path('sql/init/127_0_0_1.sql');
        if (!file_exists($sqlFile)) {
            $this->error("SQLファイルが見つかりません: $sqlFile");
            return 1;
        }

        $sql = file_get_contents($sqlFile);
        DB::unprepared($sql);

        $this->info('初期SQLの実行が完了しました');
        return 0;
    }
}
