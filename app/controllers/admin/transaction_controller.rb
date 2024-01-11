class Admin::TransactionController < ApplicationController
    before_action :require_admin!

    def new
        @transaction = Transaction.new
    end

    def create
        @transaction = current_user.transactions.new(transaction_params)
        if @transaction.save
            gn s: "Transaction created"
            redirect_to admin_transactions_path
        else
            gn a: "Transaction could not be saved"
            render :new, status: :unprocessable_entity
        end
    end

    def list
        @total = Transaction.total
        @transactions = Transaction.where(removed: false).order(created_at: :desc)
    end

    def show
        @transaction = Transaction.find_by(id: params[:transaction_id])

        return if @transaction.present?

        gn n: "Transaction doesn't exist"
        redirect_to admin_transactions_path
    end

    def removed
        @transactions = Transaction.where(removed: true).order(created_at: :desc)
    end

    def delete
        update_transaction_removed true
    end

    def restore
        update_transaction_removed false
    end

    private

    def transaction_params
        params.require(:transaction).permit(:amount, :description)
    end

    def update_transaction_removed(value)
        transaction = Transaction.find_by(id: params[:transaction_id])

        unless transaction.present?
            gn n: "Transaction doesn't exist"
            redirect_to admin_transactions_path
        end

        transaction.update(removed: value)
        gn s: "Transaction #{value ? "removed" : "restored"}"
        redirect_to admin_transactions_path
    end
end
