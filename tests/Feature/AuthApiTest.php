<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_and_receives_token(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Budi Santoso',
            'email' => 'budi@example.com',
            'password' => 'rahasia123',
            'password_confirmation' => 'rahasia123',
        ]);

        $response->assertCreated()
            ->assertJsonStructure(['message', 'token', 'token_type', 'user' => ['id', 'name', 'email']])
            ->assertJsonPath('token_type', 'Bearer');

        $this->assertDatabaseHas('users', ['email' => 'budi@example.com']);
    }

    public function test_login_succeeds_with_valid_credentials_and_fails_with_wrong_password(): void
    {
        User::factory()->create([
            'email' => 'admin@example.com',
            'password' => 'password',
        ]);

        $this->postJson('/api/login', [
            'email' => 'admin@example.com',
            'password' => 'password',
        ])->assertOk()->assertJsonStructure(['token', 'user' => ['email']]);

        $this->postJson('/api/login', [
            'email' => 'admin@example.com',
            'password' => 'salah-total',
        ])->assertStatus(422)->assertJsonValidationErrors('email');
    }

    public function test_logout_revokes_the_current_token(): void
    {
        User::factory()->create(['email' => 'admin@example.com', 'password' => 'password']);

        $token = $this->postJson('/api/login', [
            'email' => 'admin@example.com',
            'password' => 'password',
        ])->json('token');

        $this->withToken($token)->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('data.email', 'admin@example.com');

        $this->withToken($token)->postJson('/api/logout')->assertOk();

        // Reset guard yang di-cache supaya request berikutnya benar-benar dicek ulang
        $this->app['auth']->forgetGuards();

        $this->withToken($token)->getJson('/api/me')->assertUnauthorized();
    }
}
