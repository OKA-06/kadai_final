<?php

namespace Tests\Feature\Admin;

use App\Models\Admin;
use App\Models\User;
use App\Models\Category;
use Illuminate\Support\Facades\Hash;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    // 未ログインのユーザーは管理者側のカテゴリ一覧ページにアクセスできない
    public function test_guest_cannot_access_admin_categories_index()
    {
        $response = $this->get(route('admin.categories.index'));

        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの一般ユーザーは管理者側のカテゴリ一覧ページにアクセスできない
    public function test_user_cannot_access_admin_categories_index()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('admin.categories.index'));

        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの管理者は管理者側のカテゴリ一覧ページにアクセスできる
    public function test_admin_can_access_admin_categories_index()
    {
        $admin = new Admin();
        $admin->email = 'admin@example.com';
        $admin->password = Hash::make('nagoyameshi');
        $admin->save();

        $response = $this->actingAs($admin, 'admin')->get(route('admin.categories.index'));

        $response->assertStatus(200);
    }

    // 未ログインのユーザーはカテゴリを登録できない
    public function test_guest_cannot_access_admin_categories_store()
    {
        $category_data = [
            'name' => 'テスト',
        ];

        $response = $this->post(route('admin.categories.store'), $category_data);

        $this->assertDatabaseMissing('categories', $category_data);
        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの一般ユーザーはカテゴリを登録できない
    public function test_user_cannot_access_admin_categories_store()
    {
        $user = User::factory()->create();

        $category_data = [
            'name' => 'テスト',
        ];

        $response = $this->actingAs($user)->post(route('admin.categories.store'), $category_data);

        $this->assertDatabaseMissing('categories', $category_data);
        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの管理者はカテゴリを登録できる
    public function test_admin_can_access_admin_categories_store()
    {
        $admin = new Admin();
        $admin->email = 'admin@example.com';
        $admin->password = Hash::make('nagoyameshi');
        $admin->save();

        $category_data = [
            'name' => 'テスト',
        ];

        $response = $this->actingAs($admin, 'admin')->post(route('admin.categories.store'), $category_data);

        $this->assertDatabaseHas('categories', $category_data);
        $response->assertRedirect(route('admin.categories.index'));
    }

    // 未ログインのユーザーはカテゴリを更新できない
    public function test_guest_cannot_access_admin_categories_update()
    {
        $old_category = Category::factory()->create();

        $new_category_data = [
            'name' => 'テスト更新',
        ];

        $response = $this->patch(route('admin.categories.update', $old_category), $new_category_data);

        $this->assertDatabaseMissing('categories', $new_category_data);
        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの一般ユーザーはカテゴリを更新できない
    public function test_user_cannot_access_admin_categories_update()
    {
        $user = User::factory()->create();

        $old_category = Category::factory()->create();

        $new_category_data = [
            'name' => 'テスト更新',
        ];

        $response = $this->actingAs($user)->patch(route('admin.categories.update', $old_category), $new_category_data);

        $this->assertDatabaseMissing('categories', $new_category_data);
        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの管理者はカテゴリを更新できる
    public function test_admin_can_access_admin_categories_update()
    {
        $admin = new Admin();
        $admin->email = 'admin@example.com';
        $admin->password = Hash::make('nagoyameshi');
        $admin->save();

        $old_category = Category::factory()->create();

        $new_category_data = [
            'name' => 'テスト更新',
        ];

        $response = $this->actingAs($admin, 'admin')->patch(route('admin.categories.update', $old_category), $new_category_data);

        $this->assertDatabaseHas('categories', $new_category_data);
        $response->assertRedirect(route('admin.categories.index'));
    }

    // 未ログインのユーザーはカテゴリを削除できない
    public function test_guest_cannot_access_admin_categories_destroy()
    {
        $category = Category::factory()->create();

        $response = $this->delete(route('admin.categories.destroy', $category));

        $this->assertDatabaseHas('categories', ['id' => $category->id]);
        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの一般ユーザーはカテゴリを削除できない
    public function test_user_cannot_access_admin_categories_destroy()
    {
        $user = User::factory()->create();

        $category = Category::factory()->create();

        $response = $this->actingAs($user)->delete(route('admin.categories.destroy', $category));

        $this->assertDatabaseHas('categories', ['id' => $category->id]);
        $response->assertRedirect(route('admin.login'));
    }

    // ログイン済みの管理者はカテゴリを削除できる
    public function test_admin_can_access_admin_categories_destroy()
    {
        $admin = new Admin();
        $admin->email = 'admin@example.com';
        $admin->password = Hash::make('nagoyameshi');
        $admin->save();

        $category = Category::factory()->create();

        $response = $this->actingAs($admin, 'admin')->delete(route('admin.categories.destroy', $category));

        $this->assertDatabaseMissing('categories', ['id' => $category->id]);
        $response->assertRedirect(route('admin.categories.index'));
    }
}
