<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class UserController extends Controller
{
    public function index(Request $request) {
        // 検索ボックスに入力されたキーワードを取得する
        $keyword = $request->input('keyword');

        // キーワードが存在すれば検索を行い、そうでなければ全件取得する
        if ($keyword) {
            $users = User::where('name', 'like', "%{$keyword}%")->orWhere('kana', 'like', "%{$keyword}%")->paginate(15);
        } else {
            $users = User::paginate(15);
        }

        $total = $users->total();

        return view('admin.users.index', compact('users', 'keyword', 'total'));
    }

    public function show(User $user) {
        return view('admin.users.show', compact('user'));
    }
}
