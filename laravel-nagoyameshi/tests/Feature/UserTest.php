<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class UserTest extends TestCase
{
    use RefreshDatabase;

    // 未ログインのユーザーは会員側の会員情報ページにアクセスできない
    public function test_guest_cannot_access_user_index()
    {
        $response = $this->get(route('user.index'));

        $response->assertRedirect(route('login'));
    }

    // ログイン済みの一般ユーザーは会員側の会員情報ページにアクセスできる
    public function test_user_can_access_user_index()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('user.index'));

        $response->assertStatus(200);
    }

    // ログイン済みの管理者は会員側の会員情報ページにアクセスできない
    public function test_admin_cannot_access_user_index()
    {
        $admin = new Admin();
        $admin->email = 'admin@example.com';
        $admin->password = Hash::make('nagoyameshi');
        $admin->save();

        $response = $this->actingAs($admin, 'admin')->get(route('user.index'));

        $response->assertRedirect(route('admin.home'));
    }

    // 未ログインのユーザーは会員側の会員情報編集ページにアクセスできない
    public function test_guest_cannot_access_user_edit()
    {
        $user = User::factory()->create();

        $response = $this->get(route('user.edit', $user));

        $response->assertRedirect(route('login'));
    }

    // ログイン済みの一般ユーザーは会員側の他人の会員情報編集ページにアクセスできない
    public function test_user_cannot_access_others_user_edit()
    {
        $user = User::factory()->create();
        $other_user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('user.edit', $other_user));

        $response->assertRedirect(route('user.index'));
    }

    // ログイン済みの一般ユーザーは会員側の自身の会員情報編集ページにアクセスできる
    public function test_user_can_access_own_user_edit()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('user.edit', $user));

        $response->assertStatus(200);
    }

    // ログイン済みの管理者は会員側の会員情報編集ページにアクセスできない
    public function test_admin_cannot_access_user_edit()
    {
        $admin = new Admin();
        $admin->email = 'admin@example.com';
        $admin->password = Hash::make('nagoyameshi');
        $admin->save();

        $user = User::factory()->create();

        $response = $this->actingAs($admin, 'admin')->get(route('user.edit', $user));

        $response->assertRedirect(route('admin.home'));
    }

    // 未ログインのユーザーは会員情報を更新できない
    public function test_guest_cannot_access_user_update()
    {
        $old_user = User::factory()->create();

        $new_user_data = [
            'name' => 'テスト更新',
            'kana' => 'テストコウシン',
            'email' => 'test.update@example.com',
            'postal_code' => '1234567',
            'address' => 'テスト更新',
            'phone_number' => '0123456789',
            'birthday' => '20150319',
            'occupation' => 'テスト更新'
        ];

        $response = $this->patch(route('user.update', $old_user), $new_user_data);

        $this->assertDatabaseMissing('users', $new_user_data);
        $response->assertRedirect(route('login'));
    }

    // ログイン済みの一般ユーザーは他人の会員情報を更新できない
    public function test_user_cannot_access_others_user_update()
    {
        $user = User::factory()->create();
        $old_other_user = User::factory()->create();

        $new_other_user_data = [
            'name' => 'テスト更新',
            'kana' => 'テストコウシン',
            'email' => 'test.update@example.com',
            'postal_code' => '1234567',
            'address' => 'テスト更新',
            'phone_number' => '0123456789',
            'birthday' => '20150319',
            'occupation' => 'テスト更新'
        ];

        $response = $this->actingAs($user)->patch(route('user.update', $old_other_user), $new_other_user_data);

        $this->assertDatabaseMissing('users', $new_other_user_data);
        $response->assertRedirect(route('user.index'));
    }

    // ログイン済みの一般ユーザーは自身の会員情報を更新できる
    public function test_user_can_access_own_user_update()
    {
        $old_user = User::factory()->create();

        $new_user_data = [
            'name' => 'テスト更新',
            'kana' => 'テストコウシン',
            'email' => 'test.update@example.com',
            'postal_code' => '1234567',
            'address' => 'テスト更新',
            'phone_number' => '0123456789',
            'birthday' => '20150319',
            'occupation' => 'テスト更新'
        ];

        $response = $this->actingAs($old_user)->patch(route('user.update', $old_user), $new_user_data);

        $this->assertDatabaseHas('users', $new_user_data);
        $response->assertRedirect(route('user.index'));
    }

    // ログイン済みの管理者は会員情報を更新できない
    public function test_admin_cannot_access_user_update()
    {
        $admin = new Admin();
        $admin->email = 'admin@example.com';
        $admin->password = Hash::make('nagoyameshi');
        $admin->save();

        $old_user = User::factory()->create();

        $new_user_data = [
            'name' => 'テスト更新',
            'kana' => 'テストコウシン',
            'email' => 'test.update@example.com',
            'postal_code' => '1234567',
            'address' => 'テスト更新',
            'phone_number' => '0123456789',
            'birthday' => '20150319',
            'occupation' => 'テスト更新'
        ];

        $response = $this->actingAs($admin, 'admin')->patch(route('user.update', $old_user), $new_user_data);

        $this->assertDatabaseMissing('users', $new_user_data);
        $response->assertRedirect(route('admin.home'));
    }
}
