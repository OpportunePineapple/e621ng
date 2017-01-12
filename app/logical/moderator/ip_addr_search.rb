module Moderator
  class IpAddrSearch
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def execute
      if params[:user_id].present?
        search_by_user_id(params[:user_id].split(/,/).map(&:strip))
      elsif params[:user_name].present?
        search_by_user_name(params[:user_name].split(/,/).map(&:strip))
      elsif params[:ip_addr].present?
        search_by_ip_addr(params[:ip_addr].split(/,/).map(&:strip))
      else
        []
      end
    end

  private
    def select_all_sql(sql, source, *params)
      source.select_all_sql(sql, *params)
    end

    def search_by_ip_addr(ip_addrs)
      sums = Hash.new {|h, k| h[k] = 0}

      add_row(sums, "select id as k, 1 as count from users where last_ip_addr in (?)", ip_addrs)
      add_row(sums, "select creator_id as k, count(*) from comments where ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select updater_id as k, count(*) from post_versions where updater_ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select updater_id as k, count(*) from note_versions where updater_ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select updater_id as k, count(*) from pool_versions where updater_ip_addr in (?) group by k", ip_addrs, PoolArchive)
      add_row(sums, "select updater_id as k, count(*) from wiki_page_versions where updater_ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select from_id as k, count(*) from dmails where creator_ip_addr in (?) group by k", ip_addrs)

      sums
    end

    def search_by_user_name(user_names)
      user_ids = user_names.map { |name| User.name_to_id(name) }
      search_by_user_id(user_ids)
    end

    def search_by_user_id(user_ids)
      sums = Hash.new {|h, k| h[k] = 0}

      add_row(sums, "select ip_addr as k, count(*) from comments where creator_id in (?) group by k", user_ids)
      add_row(sums, "select updater_ip_addr as k, count(*) from post_versions where updater_id in (?) group by k", user_ids)
      add_row(sums, "select updater_ip_addr as k, count(*) from note_versions where updater_id in (?) group by k", user_ids)
      add_row(sums, "select updater_ip_addr as k, count(*) from pool_versions where updater_id in (?) group by k", user_ids, PoolArchive)
      add_row(sums, "select updater_ip_addr as k, count(*) from wiki_page_versions where updater_id in (?) group by k", user_ids)
      add_row(sums, "select creator_ip_addr as k, count(*) from dmails where from_id in (?) group by k", user_ids)

      sums
    end

    def add_row(sums, sql, ip_addrs, source = ActiveRecord::Base)
      select_all_sql(sql, source, ip_addrs).each do |row|
        sums[row["k"]] += row["count"].to_i
      end
    end
  end
end
