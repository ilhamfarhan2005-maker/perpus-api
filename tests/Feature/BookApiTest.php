<?php

namespace Tests\Feature;

use App\Models\Book;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BookApiTest extends TestCase
{
    use RefreshDatabase;

    private function bookPayload(array $overrides = []): array
    {
        return array_merge([
            'title' => 'Laskar Pelangi',
            'author' => 'Andrea Hirata',
            'publisher' => 'Bentang Pustaka',
            'isbn' => '9789793062792',
            'published_year' => 2005,
            'stock' => 10,
            'description' => 'Novel tentang anak-anak Belitung.',
        ], $overrides);
    }

    public function test_guest_cannot_access_books(): void
    {
        $this->getJson('/api/books')->assertUnauthorized();
        $this->postJson('/api/books', $this->bookPayload())->assertUnauthorized();
    }

    public function test_index_lists_paginated_books_and_supports_search(): void
    {
        Sanctum::actingAs(User::factory()->create());

        Book::factory()->create(['title' => 'Bumi Manusia', 'author' => 'Pramoedya']);
        Book::factory()->count(14)->create(['title' => 'Buku Acak', 'author' => 'Penulis Lain']);

        $this->getJson('/api/books?per_page=5')
            ->assertOk()
            ->assertJsonCount(5, 'data')
            ->assertJsonPath('meta.total', 15);

        $this->getJson('/api/books?search=Bumi')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Bumi Manusia');
    }

    public function test_store_creates_a_book_and_validates_input(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/books', $this->bookPayload())
            ->assertCreated()
            ->assertJsonPath('data.title', 'Laskar Pelangi');

        $this->assertDatabaseHas('books', ['isbn' => '9789793062792']);

        // ISBN duplikat dan field wajib kosong -> 422
        $this->postJson('/api/books', $this->bookPayload())
            ->assertStatus(422)
            ->assertJsonValidationErrors('isbn');

        $this->postJson('/api/books', [])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['title', 'author', 'isbn', 'published_year', 'stock']);
    }

    public function test_show_and_update_a_book(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $book = Book::factory()->create();

        $this->getJson("/api/books/{$book->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $book->id);

        $this->patchJson("/api/books/{$book->id}", ['stock' => 99])
            ->assertOk()
            ->assertJsonPath('data.stock', 99);

        // ISBN milik buku sendiri tidak dianggap duplikat
        $this->putJson("/api/books/{$book->id}", ['isbn' => $book->isbn])->assertOk();

        $this->getJson('/api/books/999999')->assertNotFound();
    }

    public function test_destroy_deletes_a_book(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $book = Book::factory()->create();

        $this->deleteJson("/api/books/{$book->id}")
            ->assertOk()
            ->assertJsonPath('message', 'Buku berhasil dihapus');

        $this->assertDatabaseMissing('books', ['id' => $book->id]);
    }
}
